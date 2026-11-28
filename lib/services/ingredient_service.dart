import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../constants/ingredient_options.dart';
import '../models/ingredient.dart';

class ServiceException implements Exception {
  final String message;
  ServiceException(this.message);
  @override
  String toString() => message;
}

class IngredientService {
  IngredientService._();
  static final IngredientService instance = IngredientService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('ingredients');

  // ---------- BACA ----------

  Stream<List<Ingredient>> watchAll() => _col.orderBy('name').snapshots().map(
        (s) => s.docs.map(Ingredient.fromDoc).where((i) => i.isActive).toList(),
  );

  Stream<Ingredient?> watchOne(String id) => _col
      .doc(id)
      .snapshots()
      .map((d) => d.exists ? Ingredient.fromDoc(d) : null);

  /// Urut dari kedaluwarsa terdekat (FEFO), batch kosong disembunyikan.
  Stream<List<Batch>> watchBatches(String ingredientId) => _col
      .doc(ingredientId)
      .collection('batches')
      .orderBy('expiryDate')
      .snapshots()
      .map((s) =>
      s.docs.map(Batch.fromDoc).where((b) => b.quantity > 0).toList());

  /// Jumlah menu aktif yang memakai bahan ini di resepnya.
  Future<int> countRecipesUsing(String ingredientId) async {
    try {
      final menus = await _db.collection('menus').get();
      var count = 0;
      for (final m in menus.docs) {
        final data = m.data();
        if (data['isActive'] == false) continue;
        final recipe = (data['recipe'] as List?) ?? const [];
        final used = recipe.any(
              (e) => e is Map && e['ingredientId'] == ingredientId,
        );
        if (used) count++;
      }
      return count;
    } on FirebaseException catch (e) {
      throw ServiceException('Gagal memeriksa resep: ${e.message ?? e.code}');
    }
  }

  // ---------- TULIS ----------

  /// minStock dan initialStock dalam satuan yang dipilih (mis. 10 untuk 10 kg).
  /// Stok awal (jika > 0) dibuat sebagai Batch 01 dengan kedaluwarsa
  /// bawaan = hari ini + masa simpan.
  Future<String> addIngredient({
    required String name,
    required String categoryKey,
    required String unitKey,
    required double minStock,
    required int shelfLifeValue,
    required String shelfLifeUnit,
    double initialStock = 0,
    String? photoUrl,
  }) async {
    final unit = unitByKey(unitKey);
    final prefix = categoryByKey(categoryKey).prefix;
    final ref = _col.doc();
    final counterRef = _db.collection('counters').doc('ingredients');

    final initialBase = (initialStock * unit.factor).round();
    final today = DateTime.now();
    final expiry = addShelfLife(
      DateTime(today.year, today.month, today.day),
      shelfLifeValue,
      shelfLifeUnit,
    );

    try {
      await _db.runTransaction((tx) async {
        final counter = await tx.get(counterRef);
        final next = ((counter.data()?['last'] as num?) ?? 0).toInt() + 1;
        final code = '$prefix-${next.toString().padLeft(3, '0')}';

        tx.set(counterRef, {'last': next});
        tx.set(ref, {
          'code': code,
          'name': name,
          'categoryKey': categoryKey,
          'unitKey': unitKey,
          'minStock': (minStock * unit.factor).round(),
          'shelfLifeValue': shelfLifeValue,
          'shelfLifeUnit': shelfLifeUnit,
          'totalStock': initialBase,
          'batchCounter': initialBase > 0 ? 1 : 0,
          if (initialBase > 0) 'nearestExpiry': Timestamp.fromDate(expiry),
          'isActive': true,
          if (photoUrl != null) 'photoUrl': photoUrl,
          'createdBy': FirebaseAuth.instance.currentUser?.uid,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        if (initialBase > 0) {
          tx.set(ref.collection('batches').doc(), {
            'batchNumber': 1,
            'quantity': initialBase,
            'initialQuantity': initialBase,
            'expiryDate': Timestamp.fromDate(expiry),
            'receivedAt': FieldValue.serverTimestamp(),
          });
        }
      });
      return ref.id;
    } on FirebaseException catch (e) {
      throw ServiceException('Gagal menyimpan bahan: ${e.message ?? e.code}');
    }
  }

  /// Ubah data bahan. Satuan dan kode tidak bisa diubah.
  /// [unitKey] hanya dipakai untuk mengonversi minStock.
  /// [photoUrl] mengganti foto; [removePhoto] menghapus foto.
  Future<void> updateIngredient(
      String id, {
        required String name,
        required String categoryKey,
        required String unitKey,
        required double minStock,
        required int shelfLifeValue,
        required String shelfLifeUnit,
        String? photoUrl,
        bool removePhoto = false,
      }) async {
    if (name.trim().isEmpty) throw ServiceException('Nama bahan wajib diisi.');
    final unit = unitByKey(unitKey);

    try {
      await _col.doc(id).update({
        'name': name.trim(),
        'categoryKey': categoryKey,
        'minStock': (minStock * unit.factor).round(),
        'shelfLifeValue': shelfLifeValue,
        'shelfLifeUnit': shelfLifeUnit,
        if (photoUrl != null) 'photoUrl': photoUrl,
        if (photoUrl == null && removePhoto) 'photoUrl': FieldValue.delete(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      throw ServiceException('Gagal memperbarui bahan: ${e.message ?? e.code}');
    }
  }

  /// Hapus bahan: bahan dinonaktifkan (riwayat stok dan batch tetap tersimpan)
  /// dan barisnya dikeluarkan dari resep semua menu. Semua dalam satu batch
  /// penulisan, jadi berhasil seluruhnya atau tidak sama sekali.
  Future<void> deleteIngredient(String id) async {
    try {
      final menus = await _db.collection('menus').get();
      final batch = _db.batch();

      for (final m in menus.docs) {
        final raw = (m.data()['recipe'] as List?) ?? const [];
        final kept = raw
            .where((e) => !(e is Map && e['ingredientId'] == id))
            .toList();
        if (kept.length != raw.length) {
          batch.update(m.reference, {
            'recipe': kept,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      }

      batch.update(_col.doc(id), {
        'isActive': false,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await batch.commit();
    } on FirebaseException catch (e) {
      throw ServiceException('Gagal menghapus bahan: ${e.message ?? e.code}');
    }
  }

  /// Tambah stok (restock) sebagai batch baru.
  /// [quantity] dalam satuan bahan (mis. 4 untuk 4 kg).
  /// [expiryDate] kosong = pakai bawaan (hari ini + masa simpan bahan).
  Future<void> addBatch({
    required String ingredientId,
    required double quantity,
    DateTime? expiryDate,
  }) async {
    if (quantity <= 0) throw ServiceException('Jumlah harus lebih dari 0.');

    final ref = _col.doc(ingredientId);
    final batchRef = ref.collection('batches').doc();

    try {
      await _db.runTransaction((tx) async {
        final snap = await tx.get(ref);
        if (!snap.exists) throw ServiceException('Bahan tidak ditemukan.');

        final data = snap.data()!;
        final unit = unitByKey(data['unitKey'] ?? 'pcs');
        final baseQty = (quantity * unit.factor).round();
        final next = ((data['batchCounter'] as num?) ?? 0).toInt() + 1;

        final now = DateTime.now();
        final expiry = expiryDate ??
            addShelfLife(
              DateTime(now.year, now.month, now.day),
              ((data['shelfLifeValue'] as num?) ?? 0).toInt(),
              (data['shelfLifeUnit'] as String?) ?? 'hari',
            );

        final hasStock = ((data['totalStock'] as num?) ?? 0) > 0;
        final current = (data['nearestExpiry'] as Timestamp?)?.toDate();
        final nearest =
        (!hasStock || current == null || expiry.isBefore(current))
            ? expiry
            : current;

        tx.set(batchRef, {
          'batchNumber': next,
          'quantity': baseQty,
          'initialQuantity': baseQty,
          'expiryDate': Timestamp.fromDate(expiry),
          'receivedAt': FieldValue.serverTimestamp(),
        });
        tx.update(ref, {
          'totalStock': FieldValue.increment(baseQty),
          'batchCounter': next,
          'nearestExpiry': Timestamp.fromDate(nearest),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });
    } on FirebaseException catch (e) {
      throw ServiceException('Gagal menambah batch: ${e.message ?? e.code}');
    }
  }
}
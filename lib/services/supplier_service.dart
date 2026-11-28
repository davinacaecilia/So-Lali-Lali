import 'package:cloud_firestore/cloud_firestore.dart';

import '../constants/supplier_options.dart';
import '../models/supplier_data.dart';
import 'ingredient_service.dart' show ServiceException;

/// Satu bahan yang akan disuplai (input untuk addSupplier).
class SupplierItemInput {
  final String ingredientId;
  final int price; // rupiah per satuan bahan
  final bool isMain; // jadikan supplier utama untuk bahan ini

  const SupplierItemInput({
    required this.ingredientId,
    required this.price,
    this.isMain = false,
  });
}

class SupplierService {
  SupplierService._();
  static final SupplierService instance = SupplierService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('suppliers');

  // ---------- BACA ----------

  Stream<List<SupplierData>> watchAll() => _col.orderBy('name').snapshots().map(
        (s) => s.docs
        .map(SupplierData.fromDoc)
        .where((x) => !x.isDeleted)
        .toList(),
  );

  Stream<SupplierData?> watchOne(String id) => _col
      .doc(id)
      .snapshots()
      .map((d) => d.exists ? SupplierData.fromDoc(d) : null);

  Stream<List<SupplierItem>> watchItems(String supplierId) => _col
      .doc(supplierId)
      .collection('items')
      .snapshots()
      .map((s) => s.docs.map(SupplierItem.fromDoc).toList());

  // ---------- TULIS ----------

  /// Menambah supplier beserta bahan yang disuplai. Kode (mis. SPJ-001)
  /// dibuat otomatis. Semua ditulis dalam satu transaksi.
  Future<String> addSupplier({
    required String name,
    required String pic,
    required String phone,
    required String email,
    required String address,
    required String paymentTerm,
    bool isActive = true,
    List<SupplierItemInput> items = const [],
  }) async {
    if (name.trim().isEmpty) throw ServiceException('Nama supplier wajib diisi.');
    if (pic.trim().isEmpty) throw ServiceException('Nama PIC wajib diisi.');

    // buang duplikat bahan (ambil yang terakhir)
    final unique = <String, SupplierItemInput>{
      for (final it in items) it.ingredientId: it,
    }.values.toList();
    for (final it in unique) {
      if (it.price <= 0) throw ServiceException('Harga bahan harus lebih dari 0.');
    }

    final ref = _col.doc();
    final counterRef = _db.collection('counters').doc('suppliers');
    final prefix = supplierPrefix(name);

    try {
      await _db.runTransaction((tx) async {
        // ---- semua baca dulu ----
        final counter = await tx.get(counterRef);
        final next = ((counter.data()?['last'] as num?) ?? 0).toInt() + 1;
        final code = '$prefix-${next.toString().padLeft(3, '0')}';

        final categoryKeys = <String>{};
        for (final it in unique) {
          final snap = await tx.get(_db.collection('ingredients').doc(it.ingredientId));
          final data = snap.data();
          if (!snap.exists || data == null || data['isActive'] == false) {
            throw ServiceException('Ada bahan yang tidak ditemukan atau sudah dihapus.');
          }
          categoryKeys.add((data['categoryKey'] as String?) ?? 'lainnya');
        }

        // ---- lalu tulis ----
        tx.set(counterRef, {'last': next});
        tx.set(ref, {
          'code': code,
          'name': name.trim(),
          'pic': pic.trim(),
          'phone': phone.trim(),
          'email': email.trim(),
          'address': address.trim(),
          'paymentTerm': paymentTerm,
          'isActive': isActive,
          'isDeleted': false,
          'categoryKeys': (categoryKeys.toList()..sort()),
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        for (final it in unique) {
          tx.set(ref.collection('items').doc(it.ingredientId), {
            'ingredientId': it.ingredientId,
            'price': it.price,
            'createdAt': FieldValue.serverTimestamp(),
          });
          if (it.isMain) {
            tx.update(_db.collection('ingredients').doc(it.ingredientId), {
              'mainSupplierId': ref.id,
              'updatedAt': FieldValue.serverTimestamp(),
            });
          }
        }
      });
      return ref.id;
    } on FirebaseException catch (e) {
      throw ServiceException('Gagal menyimpan supplier: ${e.message ?? e.code}');
    }
  }
}
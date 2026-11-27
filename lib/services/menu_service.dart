import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../constants/menu_options.dart';
import '../models/menu_data.dart';
import 'ingredient_service.dart' show ServiceException;

class MenuService {
  MenuService._();
  static final MenuService instance = MenuService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  CollectionReference<Map<String, dynamic>> get _col => _db.collection('menus');

  // ---------- BACA ----------

  Stream<List<MenuData>> watchAll() => _col.orderBy('name').snapshots().map(
        (s) => s.docs.map(MenuData.fromDoc).where((m) => m.isActive).toList(),
  );

  Stream<MenuData?> watchOne(String id) => _col
      .doc(id)
      .snapshots()
      .map((d) => d.exists ? MenuData.fromDoc(d) : null);

  // ---------- TULIS ----------

  /// Menambah menu baru. Kode (mis. MKU-001) dibuat otomatis.
  /// Takaran resep dalam satuan dasar bahan (g / ml / pcs).
  Future<String> addMenu({
    required String name,
    required String categoryKey,
    required int price,
    List<RecipeLine> recipe = const [],
    String? photoUrl,
  }) async {
    if (name.trim().isEmpty) throw ServiceException('Nama menu wajib diisi.');
    if (price <= 0) throw ServiceException('Harga harus lebih dari 0.');

    final prefix = menuCategoryByKey(categoryKey).prefix;
    final ref = _col.doc();
    final counterRef = _db.collection('counters').doc('menus');

    try {
      await _db.runTransaction((tx) async {
        final counter = await tx.get(counterRef);
        final next = ((counter.data()?['last'] as num?) ?? 0).toInt() + 1;
        final code = '$prefix-${next.toString().padLeft(3, '0')}';

        tx.set(counterRef, {'last': next});
        tx.set(ref, {
          'code': code,
          'name': name.trim(),
          'categoryKey': categoryKey,
          'price': price,
          'recipe': recipe.map((r) => r.toMap()).toList(),
          if (photoUrl != null) 'photoUrl': photoUrl,
          'isActive': true,
          'createdBy': FirebaseAuth.instance.currentUser?.uid,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });
      return ref.id;
    } on FirebaseException catch (e) {
      throw ServiceException('Gagal menyimpan menu: ${e.message ?? e.code}');
    }
  }

  Future<void> deactivate(String docId) async {
    try {
      await _col.doc(docId).update({
        'isActive': false,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      throw ServiceException('Gagal menonaktifkan menu: ${e.message ?? e.code}');
    }
  }
}
import 'package:cloud_firestore/cloud_firestore.dart';

import '../constants/ingredient_options.dart';

class Ingredient {
  final String id;
  final String code;
  final String name;
  final String categoryKey;
  final String unitKey;
  final int minStock; // satuan dasar
  final int shelfLifeValue;
  final String shelfLifeUnit; // hari | minggu | bulan
  final int totalStock; // satuan dasar
  final bool isActive;
  final DateTime? nearestExpiry; // kedaluwarsa batch terdekat
  final String? photoUrl; // link foto di Cloudinary (opsional)
  final String? mainSupplierId; // id supplier utama bahan ini (opsional)

  const Ingredient({
    required this.id,
    required this.code,
    required this.name,
    required this.categoryKey,
    required this.unitKey,
    required this.minStock,
    required this.shelfLifeValue,
    required this.shelfLifeUnit,
    required this.totalStock,
    required this.isActive,
    this.nearestExpiry,
    this.photoUrl,
    this.mainSupplierId,
  });

  factory Ingredient.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return Ingredient(
      id: doc.id,
      code: d['code'] ?? '',
      name: d['name'] ?? '',
      categoryKey: d['categoryKey'] ?? 'lainnya',
      unitKey: d['unitKey'] ?? 'pcs',
      minStock: (d['minStock'] as num? ?? 0).toInt(),
      shelfLifeValue: (d['shelfLifeValue'] as num? ?? 0).toInt(),
      shelfLifeUnit: d['shelfLifeUnit'] ?? 'hari',
      totalStock: (d['totalStock'] as num? ?? 0).toInt(),
      isActive: d['isActive'] ?? true,
      nearestExpiry: (d['nearestExpiry'] as Timestamp?)?.toDate(),
      photoUrl: d['photoUrl'] as String?,
      mainSupplierId: d['mainSupplierId'] as String?,
    );
  }

  UnitOption get unit => unitByKey(unitKey);
  CategoryOption get category => categoryByKey(categoryKey);

  /// Tanggal kedaluwarsa bawaan untuk stok masuk hari ini.
  DateTime defaultExpiry([DateTime? from]) {
    final now = from ?? DateTime.now();
    return addShelfLife(
      DateTime(now.year, now.month, now.day),
      shelfLifeValue,
      shelfLifeUnit,
    );
  }

  /// Sisa hari menuju kedaluwarsa batch terdekat (negatif = sudah lewat).
  int? get daysToNearestExpiry {
    final e = nearestExpiry;
    if (e == null || totalStock <= 0) return null;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return DateTime(e.year, e.month, e.day).difference(today).inDays;
  }

  bool get isExpired => (daysToNearestExpiry ?? 1) < 0;

  /// Sudah masuk jendela alert (H-4 minggu) tetapi belum lewat.
  bool get isExpiringSoon {
    final d = daysToNearestExpiry;
    return d != null && d >= 0 && d <= kExpiryAlertDays;
  }
}

class Batch {
  final String id;
  final int batchNumber;
  final int quantity; // satuan dasar
  final DateTime expiryDate;
  final DateTime? receivedAt;

  const Batch({
    required this.id,
    required this.batchNumber,
    required this.quantity,
    required this.expiryDate,
    this.receivedAt,
  });

  factory Batch.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return Batch(
      id: doc.id,
      batchNumber: (d['batchNumber'] as num? ?? 0).toInt(),
      quantity: (d['quantity'] as num? ?? 0).toInt(),
      expiryDate: (d['expiryDate'] as Timestamp).toDate(),
      receivedAt: (d['receivedAt'] as Timestamp?)?.toDate(),
    );
  }

  String get label => 'Batch ${batchNumber.toString().padLeft(2, '0')}';

  int get daysLeft {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final exp = DateTime(expiryDate.year, expiryDate.month, expiryDate.day);
    return exp.difference(today).inDays;
  }

  bool get isExpired => daysLeft < 0;
  bool get isExpiringSoon => !isExpired && daysLeft <= kExpiryAlertDays;
}
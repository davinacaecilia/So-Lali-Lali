import 'package:cloud_firestore/cloud_firestore.dart';

/// Satu baris resep: bahan + takaran (dalam satuan dasar bahan: g / ml / pcs).
class RecipeLine {
  final String? ingredientId;
  final String name;
  final double qty;
  final String unit;

  const RecipeLine({
    this.ingredientId,
    required this.name,
    required this.qty,
    this.unit = 'g',
  });

  factory RecipeLine.fromMap(Map<String, dynamic> m) => RecipeLine(
    ingredientId: m['ingredientId'] as String?,
    name: m['name'] ?? '',
    qty: (m['qty'] as num? ?? 0).toDouble(),
    unit: m['unit'] ?? 'g',
  );

  Map<String, dynamic> toMap() => {
    if (ingredientId != null) 'ingredientId': ingredientId,
    'name': name,
    'qty': qty,
    'unit': unit,
  };
}

/// Menu sebagaimana tersimpan di Firestore.
class MenuData {
  final String id; // id dokumen
  final String code; // mis. "MKU-001"
  final String name;
  final String categoryKey;
  final int price; // rupiah
  final List<RecipeLine> recipe;
  final String? photoUrl;
  final bool isActive;

  const MenuData({
    required this.id,
    required this.code,
    required this.name,
    required this.categoryKey,
    required this.price,
    this.recipe = const [],
    this.photoUrl,
    this.isActive = true,
  });

  factory MenuData.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    final rawRecipe = (d['recipe'] as List?) ?? const [];
    return MenuData(
      id: doc.id,
      code: d['code'] ?? '',
      name: d['name'] ?? '',
      categoryKey: d['categoryKey'] ?? 'lainnya',
      price: (d['price'] as num? ?? 0).toInt(),
      recipe: rawRecipe
          .map((e) => RecipeLine.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList(),
      photoUrl: d['photoUrl'] as String?,
      isActive: d['isActive'] ?? true,
    );
  }
}
import 'package:cloud_firestore/cloud_firestore.dart';

/// Supplier sebagaimana tersimpan di Firestore.
class SupplierData {
  final String id; // id dokumen
  final String code; // mis. "SPJ-001"
  final String name;
  final String pic;
  final String phone;
  final String email;
  final String address;
  final String paymentTerm;
  final bool isActive;
  final bool isDeleted;
  final List<String> categoryKeys; // kategori bahan yang disuplai

  const SupplierData({
    required this.id,
    required this.code,
    required this.name,
    required this.pic,
    required this.phone,
    required this.email,
    required this.address,
    required this.paymentTerm,
    this.isActive = true,
    this.isDeleted = false,
    this.categoryKeys = const [],
  });

  factory SupplierData.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return SupplierData(
      id: doc.id,
      code: d['code'] ?? '',
      name: d['name'] ?? '',
      pic: d['pic'] ?? '',
      phone: d['phone'] ?? '',
      email: d['email'] ?? '',
      address: d['address'] ?? '',
      paymentTerm: d['paymentTerm'] ?? '',
      isActive: d['isActive'] ?? true,
      isDeleted: d['isDeleted'] ?? false,
      categoryKeys: ((d['categoryKeys'] as List?) ?? const [])
          .map((e) => e.toString())
          .toList(),
    );
  }
}

/// Satu bahan yang disuplai + harganya (dokumen di suppliers/{id}/items).
class SupplierItem {
  final String ingredientId; // sama dengan id dokumen
  final int price; // rupiah per satuan bahan (mis. per kg)

  const SupplierItem({required this.ingredientId, required this.price});

  factory SupplierItem.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return SupplierItem(
      ingredientId: doc.id,
      price: (d['price'] as num? ?? 0).toInt(),
    );
  }
}
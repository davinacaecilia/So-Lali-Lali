import 'dart:async';

import 'package:flutter/material.dart';

import '../../constants/ingredient_options.dart' show categoryByKey;
import '../../constants/supplier_options.dart';
import '../../models/supplier_data.dart';
import 'tambah_supplier.dart';
import '../../services/supplier_service.dart';
import '../partials/bottom_nav.dart';
import '../partials/colors.dart';
import 'detail_supplier.dart';

class DaftarSupplierPage extends StatefulWidget {
  const DaftarSupplierPage({super.key});

  @override
  State<DaftarSupplierPage> createState() => _DaftarSupplierPageState();
}

class _DaftarSupplierPageState extends State<DaftarSupplierPage> {
  List<SupplierData> _suppliers = [];
  bool _loading = true;
  String? _error;
  StreamSubscription<List<SupplierData>>? _sub;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _sub = SupplierService.instance.watchAll().listen(
          (list) {
        if (!mounted) return;
        setState(() {
          _suppliers = list;
          _loading = false;
          _error = null;
        });
      },
      onError: (e) {
        debugPrint('supplier watchAll error: $e');
        if (!mounted) return;
        setState(() {
          _loading = false;
          _error = 'Gagal memuat data supplier.';
        });
      },
    );
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  void _pesan(String teks) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(teks)));
  }

  Future<void> _tambahSupplier() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const TambahSupplierPage()),
    );
    // Daftar diperbarui otomatis oleh stream Firestore.
  }

  void _bukaDetail(SupplierData s) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetailSupplierPage(supplierId: s.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final list = _suppliers
        .where((s) => s.name.toLowerCase().contains(_query.toLowerCase()))
        .toList();

    final theme = Theme.of(context);

    return Theme(
      data: theme.copyWith(
        textTheme: theme.textTheme.apply(fontFamily: kFont),
      ),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Column(
          children: [
            const _Header(),
            Padding(
              padding: const EdgeInsets.fromLTRB(25, 22, 25, 16),
              child:
              _SearchField(onChanged: (v) => setState(() => _query = v)),
            ),
            Expanded(child: _buildBody(list)),
          ],
        ),
        floatingActionButton: SizedBox(
          width: 54,
          height: 54,
          child: FloatingActionButton(
            onPressed: _tambahSupplier,
            backgroundColor: AppColors.orangeAccent,
            elevation: 3,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
            child: const Icon(Icons.add, color: AppColors.white, size: 26),
          ),
        ),
        bottomNavigationBar: const OwnerBottomNav(currentIndex: 2),
      ),
    );
  }

  Widget _buildBody(List<SupplierData> list) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.orangeAccent),
      );
    }
    if (_error != null) {
      return Center(
        child: Text(_error!,
            style: const TextStyle(fontSize: 14, color: AppColors.mutedText)),
      );
    }
    if (_suppliers.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            'Belum ada supplier.\nTekan tombol + untuk menambahkan.',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 14, height: 1.5, color: AppColors.mutedText),
          ),
        ),
      );
    }
    if (list.isEmpty) {
      return const Center(
        child: Text('Supplier tidak ditemukan',
            style: TextStyle(fontSize: 14, color: AppColors.mutedText)),
      );
    }

    return ListView.separated(
      // ruang bawah agar item terakhir tidak tertutup tombol +
      padding: const EdgeInsets.only(bottom: 90),
      itemCount: list.length,
      separatorBuilder: (_, __) => const Divider(
          height: 1, thickness: 1, color: AppColors.navDivider),
      itemBuilder: (_, i) => _SupplierTile(
        supplier: list[i],
        onTap: () => _bukaDetail(list[i]),
      ),
    );
  }
}

// ===== Header =====
class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.headerBg,
        boxShadow: [
          BoxShadow(
              color: AppColors.overlayShadow,
              blurRadius: 6,
              offset: Offset(0, 2)),
        ],
      ),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 14,
        bottom: 14,
        left: 28,
        right: 24,
      ),
      child: Row(
        children: [
          Image.asset(
            'assets/images/logo.png', // ganti sesuai path logo kamu
            width: 52,
            height: 52,
            errorBuilder: (_, __, ___) => const Icon(Icons.local_cafe,
                size: 44, color: AppColors.brownDark),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('SO LALI LALI',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.brownDark)),
                Text('Dashboard Owner',
                    style: TextStyle(
                        fontSize: 16, color: AppColors.headerText)),
              ],
            ),
          ),
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.headerBg,
              border: Border.all(color: AppColors.neutralBorder),
            ),
            child: const Icon(Icons.notifications_none,
                color: AppColors.textDark, size: 24),
          ),
          const SizedBox(width: 6),
          ClipOval(
            child: Image.asset(
              'assets/images/avatar.png', // ganti sesuai path foto profil
              width: 46,
              height: 46,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 46,
                height: 46,
                color: AppColors.iconBox,
                child: const Icon(Icons.person, color: AppColors.brownDark),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ===== Search =====
class _SearchField extends StatelessWidget {
  final ValueChanged<String> onChanged;
  const _SearchField({required this.onChanged});

  OutlineInputBorder _border() => OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: const BorderSide(color: AppColors.fieldBorder),
  );

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: 'Cari nama supplier',
        hintStyle: const TextStyle(fontSize: 14, color: AppColors.fieldHint),
        prefixIcon: const Icon(
          Icons.search,
          size: 20,
          color: AppColors.mutedIcon,
        ),
        filled: true,
        fillColor: AppColors.fieldBg,
        contentPadding: EdgeInsets.zero,
        enabledBorder: _border(),
        focusedBorder: _border(),
      ),
    );
  }
}

// ===== Item Supplier =====
class _SupplierTile extends StatelessWidget {
  final SupplierData supplier;
  final VoidCallback onTap;
  const _SupplierTile({required this.supplier, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final kategori =
    supplier.categoryKeys.map((k) => categoryByKey(k).label).toList();

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(25, 14, 20, 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.iconBox,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(supplierInitials(supplier.name),
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.warningStatusText)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(supplier.name,
                      style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark)),
                  const SizedBox(height: 2),
                  Text('PIC: ${supplier.pic} · ${supplier.phone}',
                      style: const TextStyle(
                          fontSize: 13.5, color: AppColors.neutralText)),
                  if (kategori.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: kategori
                          .map((k) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.chipBg,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(k,
                            style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: AppColors.deepBrown)),
                      ))
                          .toList(),
                    ),
                  ],
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 14),
              child: Icon(Icons.chevron_right, color: AppColors.neutralText),
            ),
          ],
        ),
      ),
    );
  }
}
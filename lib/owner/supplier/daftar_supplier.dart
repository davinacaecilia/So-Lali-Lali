import 'package:flutter/material.dart';

import '../partials/colors.dart';
import '../partials/bottom_nav.dart';
import 'detail_supplier.dart';
import 'tambah_supplier.dart';

class Supplier {
  final String nama;
  final String pic;
  final String telp;
  final List<String> kategori;
  final String email;
  final String alamat;
  final String termin;
  final bool aktif;

  /// true untuk supplier yang baru ditambahkan (belum punya bahan).
  final bool bahanKosong;

  const Supplier(
    this.nama,
    this.pic,
    this.telp,
    this.kategori, {
    this.email = 'order@sumberpanganjaya.co.id',
    this.alamat = 'Jl. Industri No. 21, Kawasan Industri',
    this.termin = '14 hari',
    this.aktif = true,
    this.bahanKosong = false,
  });
}

const _dataSupplier = [
  Supplier('CV Sumber Pangan Jaya', 'Pak Hendra', '0812-3456-7890',
      ['Bahan Kering', 'Bumbu']),
  Supplier('CV Sumber Pangan Jaya', 'Pak Hendra', '0812-3456-7890',
      ['Sayur dan Buah']),
  Supplier('CV Sumber Pangan Jaya', 'Pak Hendra', '0812-3456-7890',
      ['Susu dan Olahan']),
  Supplier('CV Sumber Pangan Jaya', 'Pak Hendra', '0812-3456-7890',
      ['Minuman']),
  Supplier('CV Sumber Pangan Jaya', 'Pak Hendra', '0812-3456-7890',
      ['Bumbu']),
];

/// Inisial: lewati awalan badan usaha 2 huruf (CV, PT, UD, ...).
String _inisial(String nama) {
  final w = nama.split(' ').where((e) => e.isNotEmpty).toList();
  if (w.isEmpty) return '?';
  final isi = (w.length > 1 && w.first.length <= 2) ? w.skip(1) : w;
  return isi.take(2).map((e) => e[0].toUpperCase()).join();
}

class DaftarSupplierPage extends StatefulWidget {
  const DaftarSupplierPage({super.key});

  @override
  State<DaftarSupplierPage> createState() => _DaftarSupplierPageState();
}

class _DaftarSupplierPageState extends State<DaftarSupplierPage> {
  final List<Supplier> _suppliers = List.of(_dataSupplier);
  String _query = '';

  Future<void> _tambahSupplier() async {
    final hasil = await Navigator.push<TambahSupplierResult>(
      context,
      MaterialPageRoute(builder: (_) => const TambahSupplierPage()),
    );
    if (!mounted || hasil == null) return;

    setState(() {
      _suppliers.insert(
        0,
        Supplier(
          hasil.nama,
          hasil.pic,
          hasil.telp,
          hasil.kategori,
          email: hasil.email,
          alamat: hasil.alamat,
          termin: hasil.termin,
          aktif: hasil.aktif,
          bahanKosong: true,
        ),
      );
    });
    // Toast sukses ditampilkan dari halaman Tambah Supplier langkah 2.
  }

  void _bukaDetail(Supplier s) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetailSupplierPage(
          nama: s.nama,
          pic: s.pic,
          telp: s.telp,
          email: s.email,
          alamat: s.alamat,
          termin: s.termin,
          aktif: s.aktif,
          // supplier baru: kosong. Lainnya: pakai data dummy.
          bahan: s.bahanKosong ? const [] : null,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final list = _suppliers
        .where((s) => s.nama.toLowerCase().contains(_query.toLowerCase()))
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
            Expanded(
              child: list.isEmpty
                  ? const Center(
                      child: Text('Supplier tidak ditemukan',
                          style: TextStyle(
                              fontSize: 14, color: AppColors.mutedText)),
                    )
                  : ListView.separated(
                      // ruang bawah agar item terakhir tidak tertutup tombol +
                      padding: const EdgeInsets.only(bottom: 90),
                      itemCount: list.length,
                      separatorBuilder: (_, __) => const Divider(
                          height: 1,
                          thickness: 1,
                          color: AppColors.navDivider),
                      itemBuilder: (_, i) => _SupplierTile(
                        supplier: list[i],
                        onTap: () => _bukaDetail(list[i]),
                      ),
                    ),
            ),
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
  final Supplier supplier;
  final VoidCallback onTap;
  const _SupplierTile({required this.supplier, required this.onTap});

  @override
  Widget build(BuildContext context) {
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
              child: Text(_inisial(supplier.nama),
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
                  Text(supplier.nama,
                      style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark)),
                  const SizedBox(height: 2),
                  Text('PIC: ${supplier.pic} · ${supplier.telp}',
                      style: const TextStyle(
                          fontSize: 13.5, color: AppColors.neutralText)),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: supplier.kategori
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
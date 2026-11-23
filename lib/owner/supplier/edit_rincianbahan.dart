import 'package:flutter/material.dart';

import 'popup_pilihbahan.dart'
    show
        showPilihBahanSheet,
        PilihBahanMode,
        PickedBahan,
        daftarBahanContoh;

// ====== Warna ======
class AppColors {
  static const background = Colors.white;
  static const headerBg = Color(0xFFFFF8F0);
  static const supplierBg = Color(0xFFFFF3EA);
  static const avatarBg = Color(0xFFFFDDB0);
  static const brown = Color(0xFF7A4A12);
  static const textDark = Color(0xFF2B1D14);
  static const textGrey = Color(0xFF6B6259);
  static const border = Color(0xFF7A4A12);
  static const addBg = Color(0xFFFFEEE2);
  static const primary = Color(0xFFE69F2E);
  static const danger = Color(0xFFD7263D);
}

// ====== Model sederhana (khusus tampilan) ======
class BahanItem {
  final String nama;
  final String harga;
  const BahanItem({required this.nama, required this.harga});
}

class EditInformasiMenuPage extends StatefulWidget {
  const EditInformasiMenuPage({super.key});

  @override
  State<EditInformasiMenuPage> createState() => _EditInformasiMenuPageState();
}

class _EditInformasiMenuPageState extends State<EditInformasiMenuPage> {
  final List<BahanItem> _bahan = const [
    BahanItem(nama: 'Biji Kopi Arabika', harga: 'Rp 22.000'),
    BahanItem(nama: 'Gula Pasir', harga: 'Rp 16.000'),
  ].toList();

  void _hapus(int index) => setState(() => _bahan.removeAt(index));

  static String _fmtRupiah(int v) {
    final s = v.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return 'Rp $buf';
  }

  /// Buka popup Pilih Bahan (bottom sheet, mode supplier).
  Future<void> _tambah() async {
    final PickedBahan? hasil = await showPilihBahanSheet(
      context,
      options: daftarBahanContoh, // TODO: ganti dengan data dari API
      usedNames: _bahan.map((b) => b.nama.toLowerCase()).toSet(),
      usedLabel: 'Sudah disuplai',
      mode: PilihBahanMode.supplier,
      onTambahBaru: () {
        // TODO: buka halaman tambah bahan baru
      },
    );

    if (hasil == null || !mounted) return;
    setState(() {
      _bahan.add(BahanItem(
        nama: hasil.option.name,
        harga: _fmtRupiah(hasil.price),
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const _Header(),
          const _SupplierCard(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        'Bahan yang DIsuplai',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                      Text(
                        '*Wajib',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.danger,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  for (int i = 0; i < _bahan.length; i++) ...[
                    _BahanRow(item: _bahan[i], onRemove: () => _hapus(i)),
                    const SizedBox(height: 12),
                  ],
                  _AddButton(onTap: _tambah),
                ],
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: _SaveButton(onPressed: () {
                // TODO: logika simpan
              }),
            ),
          ),
        ],
      ),
    );
  }
}

// ====== Header / AppBar ======
class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.headerBg,
        boxShadow: [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 64,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  icon: const Icon(Icons.arrow_back,
                      color: AppColors.textDark, size: 22),
                  onPressed: () => Navigator.maybePop(context),
                ),
              ),
              const Text(
                'Edit Informasi Menu',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ====== Kartu Supplier ======
class _SupplierCard extends StatelessWidget {
  const _SupplierCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.supplierBg,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.avatarBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'SP',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.brown,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'CV Sumber Pangan Jaya',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'PIC: Pak Hendra · 0812-3456-7890',
                  style: TextStyle(fontSize: 12, color: AppColors.textGrey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ====== Baris Bahan ======
class _BahanRow extends StatelessWidget {
  final BahanItem item;
  final VoidCallback onRemove;

  const _BahanRow({required this.item, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: AppColors.border, width: 1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  item.nama,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textDark,
                  ),
                ),
                Text(
                  item.harga,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.brown,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        InkWell(
          onTap: onRemove,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            width: 60,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: AppColors.border, width: 1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.remove, size: 20, color: AppColors.brown),
          ),
        ),
      ],
    );
  }
}

// ====== Tombol Tambah Bahan ======
class _AddButton extends StatelessWidget {
  final VoidCallback onTap;

  const _AddButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.addBg,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          height: 56,
          width: double.infinity,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.add_circle_outline,
                  size: 20, color: AppColors.textDark),
              SizedBox(width: 8),
              Text(
                'Tambah Bahan',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ====== Tombol Simpan ======
class _SaveButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _SaveButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: const Icon(Icons.check_circle_outline, size: 20),
        label: const Text(
          'Simpan Perubahan',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
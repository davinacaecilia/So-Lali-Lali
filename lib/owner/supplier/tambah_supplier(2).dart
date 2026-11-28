import 'dart:async';

import 'package:flutter/material.dart';

import '../../constants/supplier_options.dart';
import '../../models/ingredient.dart';
import '../../services/ingredient_service.dart';
import '../../services/supplier_service.dart';
import '../partials/colors.dart';
import 'detail_supplier.dart';
import 'popup_pilihbahan.dart';

/// Toast sukses (kotak cokelat gelap, ikon centang hijau, aksi "Lihat").
/// Bisa dipakai ulang di halaman lain.
void tampilToastSukses(
    ScaffoldMessengerState messenger,
    String pesan, {
      VoidCallback? onLihat,
      String labelAksi = 'Lihat',
    }) {
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        // fixed = menempel tepat di atas bottom nav (seperti snackbar lama),
        // FAB otomatis ikut naik. floating akan muncul di atas FAB.
        behavior: SnackBarBehavior.fixed,
        backgroundColor: Colors.transparent,
        elevation: 0,
        clipBehavior: Clip.none,
        padding: const EdgeInsets.symmetric(horizontal: 25),
        duration: const Duration(seconds: 4),
        content: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          decoration: BoxDecoration(
            color: const Color(0xFF3B2A1A),
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.check, size: 20, color: Color(0xFF5FD38D)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  pesan,
                  style: const TextStyle(
                    fontFamily: kFont,
                    fontSize: 14.5,
                    color: Colors.white,
                  ),
                ),
              ),
              if (onLihat != null) ...[
                const SizedBox(width: 12),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    messenger.hideCurrentSnackBar();
                    onLihat();
                  },
                  child: Text(
                    labelAksi,
                    style: const TextStyle(
                      fontFamily: kFont,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFF2C94C),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
}

/// Bahan yang dipilih di langkah 2 (belum disimpan).
class _BahanDipilih {
  final BahanOption option;
  final int price; // rupiah per satuan bahan
  final bool isMain; // dijadikan supplier utama untuk bahan ini

  const _BahanDipilih(this.option, this.price, this.isMain);
}

class TambahSupplier2Page extends StatefulWidget {
  // Data dari langkah 1
  final String nama;
  final String pic;
  final String telp;
  final String email;
  final String alamat;

  const TambahSupplier2Page({
    super.key,
    required this.nama,
    required this.pic,
    required this.telp,
    required this.email,
    required this.alamat,
  });

  @override
  State<TambahSupplier2Page> createState() => _TambahSupplier2PageState();
}

class _TambahSupplier2PageState extends State<TambahSupplier2Page> {
  String? _termin = '14 hari';
  final List<_BahanDipilih> _bahan = [];

  // Daftar bahan asli dari Firestore (realtime)
  List<Ingredient>? _ingredients;
  StreamSubscription<List<Ingredient>>? _sub;

  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _sub = IngredientService.instance.watchAll().listen(
          (list) {
        if (mounted) setState(() => _ingredients = list);
      },
      onError: (e) => debugPrint('bahan watchAll error: $e'),
    );
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  bool get _valid => _termin != null && _bahan.isNotEmpty;

  void _pesan(String teks) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(teks)));
  }

  /// Simpan supplier + bahannya ke Firestore, lalu kembali ke daftar.
  Future<void> _simpan() async {
    if (!_valid || _saving) return;

    // Ambil messenger & navigator sebelum halaman ditutup, supaya toast
    // dan tombol "Lihat" tetap berfungsi setelah pop.
    final messenger = ScaffoldMessenger.of(context);
    final nav = Navigator.of(context);

    setState(() => _saving = true);
    try {
      final id = await SupplierService.instance.addSupplier(
        name: widget.nama,
        pic: widget.pic,
        phone: widget.telp,
        email: widget.email,
        address: widget.alamat,
        paymentTerm: _termin!,
        isActive: true,
        items: _bahan
            .map(
              (b) => SupplierItemInput(
            ingredientId: b.option.id,
            price: b.price,
            isMain: b.isMain,
          ),
        )
            .toList(),
      );
      if (!mounted) return;

      nav.pop(id); // -> langkah 1 -> daftar supplier

      tampilToastSukses(
        messenger,
        'Supplier berhasil ditambahkan',
        onLihat: () => nav.push(
          MaterialPageRoute(builder: (_) => DetailSupplierPage(supplierId: id)),
        ),
      );
    } on ServiceException catch (e) {
      _pesan(e.message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  /// Klik "Tambah Bahan" -> popup Pilih Bahan (mode supplier).
  Future<void> _tambahBahan() async {
    final semua = _ingredients;
    if (semua == null) {
      _pesan('Memuat daftar bahan, coba lagi sebentar.');
      return;
    }
    if (semua.isEmpty) {
      _pesan('Belum ada bahan. Tambahkan bahan dulu di tab Bahan.');
      return;
    }

    final picked = await showPilihBahanSheet(
      context,
      options: semua.map(BahanOption.fromIngredient).toList(),
      usedIds: _bahan.map((b) => b.option.id).toSet(),
      onTambahBaru: () =>
          _pesan('Tambahkan bahan baru lewat tab Bahan, lalu kembali ke sini.'),
      mode: PilihBahanMode.supplier,
      usedLabel: 'Sudah ditambahkan',
    );
    if (!mounted || picked == null) return;

    setState(() {
      _bahan.add(_BahanDipilih(picked.option, picked.price, picked.isMain));
    });
  }

  // ===== Komponen =====
  Widget _label(String text, {String? subtitle}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(text,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark)),
              if (subtitle != null)
                Text(subtitle,
                    style: const TextStyle(
                        fontSize: 13, color: AppColors.warmSubtitle)),
            ],
          ),
          const Text('*Wajib',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.red)),
        ],
      ),
    );
  }

  OutlineInputBorder _border({double width = 1}) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide: BorderSide(color: AppColors.brown, width: width),
  );

  // ===== Indikator langkah =====
  Widget _buildProgress() {
    Widget bar() => Container(
      height: 5,
      decoration: BoxDecoration(
        color: AppColors.orangeAccent,
        borderRadius: BorderRadius.circular(3),
      ),
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(25, 16, 25, 0),
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Langkah 2 dari 2',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.accent)),
              Text('INFORMASI LANJUTAN',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.4,
                      color: AppColors.mutedBrown)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: bar()),
              const SizedBox(width: 8),
              Expanded(child: bar()),
            ],
          ),
        ],
      ),
    );
  }

  // ===== Termin =====
  Widget _buildTermin() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('Termin Pembayaran',
            subtitle: 'Kesepakatan waktu pelunasan transaksi'),
        const SizedBox(height: 2),
        DropdownButtonFormField<String>(
          value: _termin,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down,
              color: AppColors.brown, size: 24),
          dropdownColor: AppColors.background,
          borderRadius: BorderRadius.circular(10),
          style: const TextStyle(fontSize: 14.5, color: AppColors.brown),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.background,
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            enabledBorder: _border(),
            focusedBorder: _border(width: 1.6),
          ),
          items: kPaymentTerms
              .map((t) => DropdownMenuItem(value: t, child: Text(t)))
              .toList(),
          onChanged: (v) => setState(() => _termin = v),
        ),
      ],
    );
  }

  // ===== Daftar bahan =====
  Widget _buildBahan() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('Bahan yang Disuplai'),
        if (_bahan.isEmpty)
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Text('Belum ada bahan. Tambahkan minimal satu bahan.',
                style: TextStyle(fontSize: 12.5, color: AppColors.photoHint)),
          ),
        ..._bahan.asMap().entries.map((e) => _barisBahan(e.key, e.value)),
        const SizedBox(height: 2),
        _tombolTambahBahan(),
      ],
    );
  }

  Widget _barisBahan(int index, _BahanDipilih b) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: SizedBox(
        height: 56,
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.brown, width: 1),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(7),
                  child: Row(
                    children: [
                      // nama bahan (+ tanda "Utama")
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: Row(
                            children: [
                              Flexible(
                                child: Text(
                                  b.option.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: AppColors.textDark,
                                  ),
                                ),
                              ),
                              if (b.isMain) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: AppColors.chipBg,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                  child: const Text('Utama',
                                      style: TextStyle(
                                          fontSize: 10,
                                          color: AppColors.warmSubtitle)),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      // harga + satuan (kotak krem di kanan)
                      Container(
                        height: double.infinity,
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        decoration: const BoxDecoration(
                          color: Color(0xFFF3E8D6),
                          border: Border(
                            left: BorderSide(color: AppColors.brown, width: 1),
                          ),
                        ),
                        child: Text(
                          '${formatRupiah(b.price)}/${b.option.displayUnit}',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.brown,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 11),
            // tombol hapus baris
            InkWell(
              onTap: () => setState(() => _bahan.removeAt(index)),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 60,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.brown, width: 1),
                ),
                child: const Icon(Icons.remove,
                    size: 20, color: AppColors.textDark),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tombolTambahBahan() {
    return Material(
      color: AppColors.filterRowBg,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: _tambahBahan,
        borderRadius: BorderRadius.circular(8),
        child: const SizedBox(
          width: double.infinity,
          height: 56,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_circle_outline,
                  size: 20, color: AppColors.textDark),
              SizedBox(width: 8),
              Text('Tambah Bahan',
                  style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark)),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Theme(
      data: theme.copyWith(
        textTheme: theme.textTheme.apply(fontFamily: kFont),
      ),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Column(
          children: [
            _Header(onBack: _saving ? () {} : () => Navigator.pop(context)),
            _buildProgress(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(25, 22, 25, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTermin(),
                    const SizedBox(height: 22),
                    _buildBahan(),
                  ],
                ),
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(25, 8, 25, 18),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: (_valid && !_saving) ? _simpan : null,
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: AppColors.orangeAccent,
                      foregroundColor: AppColors.white,
                      disabledBackgroundColor: AppColors.buttonBg,
                      disabledForegroundColor: AppColors.buttonText,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: _saving
                        ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                        : const Text('Tambah Supplier',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ===== Header =====
class _Header extends StatelessWidget {
  final VoidCallback onBack;
  const _Header({required this.onBack});

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
        left: 20,
        right: 20,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack,
            behavior: HitTestBehavior.opaque,
            child: const Icon(Icons.arrow_back,
                size: 24, color: AppColors.textDark),
          ),
          const Expanded(
            child: Text('Tambah Supplier Baru',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark)),
          ),
          const SizedBox(width: 24),
        ],
      ),
    );
  }
}
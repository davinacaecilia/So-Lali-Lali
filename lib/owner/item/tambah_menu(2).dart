import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../constants/menu_options.dart';
import '../../models/ingredient.dart';
import '../../models/menu_data.dart';
import '../../services/cloudinary_service.dart';
import '../../services/ingredient_service.dart';
import '../../services/menu_service.dart';
import '../partials/colors.dart';
import 'popup_pilihbahan.dart';
import 'tambah_menu.dart'; // MenuDasar

/// Kompatibilitas: model lama (biaya bahan). Tidak dipakai lagi oleh halaman
/// tambah menu; dibiarkan kalau halaman edit masih memakainya.
class BahanResep {
  final String name;
  final String unit;
  final double pricePerUnit;

  const BahanResep({
    required this.name,
    required this.unit,
    required this.pricePerUnit,
  });
}

/// Satu baris resep: bahan (dari Firestore) + takaran per porsi.
class _BarisResep {
  BahanOption? bahan;
  final TextEditingController qty = TextEditingController();

  double get qtyValue =>
      double.tryParse(qty.text.trim().replaceAll(',', '.')) ?? 0;

  bool get lengkap => bahan != null && qtyValue > 0;
}

// =====================================================
// HALAMAN LANGKAH 2
// =====================================================
class TambahMenuResepPage extends StatefulWidget {
  final MenuDasar dasar;

  const TambahMenuResepPage({super.key, required this.dasar});

  @override
  State<TambahMenuResepPage> createState() => _TambahMenuResepPageState();
}

class _TambahMenuResepPageState extends State<TambahMenuResepPage> {
  // Warna khusus halaman ini (dari desain).
  static const _headerBg = Color(0xFFFBF7EE);
  static const _border = Color(0xFF7A4A12);
  static const _stepActive = Color(0xFFE8A22B);
  static const _label = Color(0xFF3A2208);
  static const _required = Color(0xFFD0021B);
  static const _cardBg = Color(0xFFFEEFE3);
  static const _cardBorder = Color(0xFFF3D5BC);
  static const _priceChipBg = Color(0xFFFBDCC3);
  static const _addBg = Color(0xFFFEEFE3);
  static const _fcTitle = Color(0xFF8A3B12);

  final List<_BarisResep> _rows = [_BarisResep()];

  // Daftar bahan asli dari Firestore (realtime)
  List<Ingredient>? _bahan;
  StreamSubscription<List<Ingredient>>? _sub;

  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _sub = IngredientService.instance.watchAll().listen(
          (list) {
        if (mounted) setState(() => _bahan = list);
      },
      onError: (e) => debugPrint('bahan watchAll error: $e'),
    );
  }

  @override
  void dispose() {
    _sub?.cancel();
    for (final r in _rows) {
      r.qty.dispose();
    }
    super.dispose();
  }

  bool get _valid => _rows.isNotEmpty && _rows.every((r) => r.lengkap);

  // ---------- Aksi ----------
  void _pesan(String teks) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(teks)));
  }

  void _removeRow(int i) {
    setState(() {
      final r = _rows.removeAt(i);
      r.qty.dispose();
    });
  }

  /// Membuka bottom sheet pilih bahan (bahan asli dari Firestore).
  /// Bahan yang sudah dipakai di resep tidak bisa dipilih dua kali.
  Future<PickedBahan?> _bukaPopupPilihBahan({int? excludeIndex}) async {
    final bahan = _bahan;
    if (bahan == null) {
      _pesan('Memuat daftar bahan, coba lagi sebentar.');
      return null;
    }
    if (bahan.isEmpty) {
      _pesan('Belum ada bahan. Tambahkan bahan dulu di tab Bahan.');
      return null;
    }

    final usedIds = _rows
        .asMap()
        .entries
        .where((e) => e.key != excludeIndex && e.value.bahan != null)
        .map((e) => e.value.bahan!.id)
        .toSet();

    return showPilihBahanSheet(
      context,
      options: bahan.map(BahanOption.fromIngredient).toList(),
      usedIds: usedIds,
    );
  }

  static String _fmtQty(double v) =>
      v == v.roundToDouble() ? v.toInt().toString() : v.toString();

  void _isiBarisDenganHasil(_BarisResep row, PickedBahan hasil) {
    row.bahan = hasil.option;
    row.qty.text = _fmtQty(hasil.qty);
  }

  /// Dipakai ketika pengguna menekan nama bahan pada baris yang sudah ada.
  Future<void> _pilihBahan(int i) async {
    final hasil = await _bukaPopupPilihBahan(excludeIndex: i);
    if (!mounted || hasil == null) return;
    setState(() => _isiBarisDenganHasil(_rows[i], hasil));
  }

  /// Dipakai ketika tombol (+) Tambah Bahan ditekan.
  /// Mengisi baris kosong pertama; jika tidak ada, membuat baris baru.
  Future<void> _tambahBahan() async {
    final hasil = await _bukaPopupPilihBahan();
    if (!mounted || hasil == null) return;

    setState(() {
      final indexKosong = _rows.indexWhere((row) => row.bahan == null);
      if (indexKosong != -1) {
        _isiBarisDenganHasil(_rows[indexKosong], hasil);
      } else {
        final rowBaru = _BarisResep();
        _isiBarisDenganHasil(rowBaru, hasil);
        _rows.add(rowBaru);
      }
    });
  }

  /// Unggah foto (jika ada) -> simpan menu + resep ke Firestore.
  Future<void> _submit() async {
    if (!_valid || _saving) return;

    final messenger = ScaffoldMessenger.of(context);
    setState(() => _saving = true);
    try {
      // 1) foto -> link Cloudinary
      String? photoUrl;
      if (widget.dasar.foto != null) {
        photoUrl = await CloudinaryService.instance.uploadImage(
          widget.dasar.foto!,
        );
      }

      // 2) simpan menu
      await MenuService.instance.addMenu(
        name: widget.dasar.name,
        categoryKey: widget.dasar.categoryKey,
        price: widget.dasar.price,
        photoUrl: photoUrl,
        recipe: _rows
            .map(
              (r) => RecipeLine(
            ingredientId: r.bahan!.id,
            name: r.bahan!.name,
            qty: r.qtyValue,
            unit: r.bahan!.unit,
          ),
        )
            .toList(),
      );
      if (!mounted) return;

      _showSuccessToast(messenger);
      Navigator.pop(context, true); // -> langkah 1 -> daftar menu
    } on ServiceException catch (e) {
      _pesan(e.message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showSuccessToast(ScaffoldMessengerState messenger) {
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.toastBg,
          elevation: 6,
          duration: const Duration(seconds: 3),
          margin: const EdgeInsets.fromLTRB(25, 0, 25, 24),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          content: const Row(
            children: [
              Icon(Icons.check, size: 20, color: AppColors.toastCheck),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Menu berhasil ditambahkan',
                  style: TextStyle(fontSize: 14, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
  }

  // ---------- Format ----------
  static String _rupiah(num v) {
    final s = v.round().toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return 'Rp $buf';
  }

  // =====================================================
  // BUILD
  // =====================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: _headerBg,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
          onPressed: _saving ? null : () => Navigator.pop(context),
        ),
        title: const Text(
          'Tambahkan Menu Baru',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(25, 20, 25, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStepper(),
                    const SizedBox(height: 18),
                    _buildSummaryCard(),
                    const SizedBox(height: 20),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Rincian Resep',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: _label,
                          ),
                        ),
                        Text(
                          '*Wajib',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: _required,
                          ),
                        ),
                      ],
                    ),
                    const Text(
                      'Takaran untuk satu porsi',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.brownDark,
                      ),
                    ),
                    const SizedBox(height: 10),
                    for (var i = 0; i < _rows.length; i++) ...[
                      _buildRow(i),
                      const SizedBox(height: 10),
                    ],
                    _buildAddButton(),
                  ],
                ),
              ),
            ),
            _buildBottomPanel(),
          ],
        ),
      ),
    );
  }

  // =====================================================
  // KOMPONEN
  // =====================================================
  Widget _buildStepper() {
    Widget bar() => Expanded(
      child: Container(
        height: 5,
        decoration: BoxDecoration(
          color: _stepActive,
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );

    return Column(
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Langkah 2 dari 2',
              style: TextStyle(fontSize: 13.5, color: AppColors.brownDark),
            ),
            Text(
              'RINCIAN RESEP',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.4,
                color: AppColors.brownDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(children: [bar(), const SizedBox(width: 8), bar()]),
      ],
    );
  }

  Widget _buildSummaryCard() {
    final fallback = Container(
      color: AppColors.peach,
      child: const Icon(Icons.restaurant_menu, color: AppColors.brown),
    );
    final foto = widget.dasar.foto;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _cardBorder),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 63,
              height: 63,
              child: foto != null
                  ? Image.file(
                foto,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => fallback,
              )
                  : fallback,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.dasar.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                Text(
                  menuCategoryByKey(widget.dasar.categoryKey).label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.lightSubtitle,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: _priceChipBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _rupiah(widget.dasar.price),
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.brownDark,
              ),
            ),
          ),
          const SizedBox(width: 6),
        ],
      ),
    );
  }

  /// [ Nama bahan | 18 g ]  [ - ]
  Widget _buildRow(int i) {
    final r = _rows[i];

    return Row(
      children: [
        Expanded(
          child: Container(
            height: 54,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _border),
            ),
            clipBehavior: Clip.antiAlias,
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _pilihBahan(i),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          r.bahan?.name ?? 'Pilih bahan',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 15,
                            color: r.bahan == null
                                ? AppColors.fieldHint
                                : AppColors.textDark,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Container(width: 1, color: _border),
                SizedBox(
                  width: 90,
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: r.qty,
                          textAlign: TextAlign.right,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'[0-9.,]'),
                            ),
                          ],
                          onChanged: (_) => setState(() {}),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.brownDark,
                          ),
                          decoration: const InputDecoration(
                            hintText: '0',
                            hintStyle: TextStyle(
                              fontSize: 15,
                              color: AppColors.fieldHint,
                            ),
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      const SizedBox(width: 3),
                      Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: Text(
                          r.bahan?.unit ?? 'g',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.brownDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        // Tombol hapus baris
        Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: _rows.length > 1 ? () => _removeRow(i) : null,
            child: Container(
              width: 60,
              height: 54,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _border),
              ),
              child: Icon(
                Icons.remove,
                size: 20,
                color: _rows.length > 1 ? _border : AppColors.fieldHint,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddButton() {
    return Material(
      color: _addBg,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: _tambahBahan,
        child: const SizedBox(
          height: 56,
          width: double.infinity,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_circle_outline, size: 20, color: AppColors.textDark),
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

  // ---------- Panel bawah: jumlah bahan + tombol ----------
  Widget _buildBottomPanel() {
    final terisi = _rows.where((r) => r.bahan != null).length;

    return Container(
      padding: const EdgeInsets.fromLTRB(25, 14, 25, 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.cardBorder)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Bahan dalam resep',
                style: TextStyle(fontSize: 13.5, color: AppColors.brownDark),
              ),
              Text(
                '$terisi bahan',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: (_valid && !_saving) ? _submit : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _stepActive,
                foregroundColor: Colors.white,
                disabledBackgroundColor: _priceChipBg,
                disabledForegroundColor: _fcTitle,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
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
                  : const Text(
                'Tambahkan Menu',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
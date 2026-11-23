import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../partials/colors.dart';
import 'daftar_menu.dart'; // MenuModel
import 'filter_menu.dart'; // foodCostStatusOf
import 'tambah_menu.dart'; // MenuDasar
import 'popup_pilihbahan.dart'; // showPilihBahanSheet, PickedBahan, daftarBahanContoh

// Model bahan yang dipakai untuk menghitung biaya resep.
// pricePerUnit mengikuti satuan dari popup, misalnya Rp/kg atau Rp/liter.
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

/// Satu baris resep: bahan + takaran.
class _BarisResep {
  BahanResep? bahan;
  final TextEditingController qty = TextEditingController();

  double get qtyValue =>
      double.tryParse(qty.text.trim().replaceAll(',', '.')) ?? 0;

  bool get lengkap => bahan != null && qtyValue > 0;

  double get biaya => bahan == null ? 0 : bahan!.pricePerUnit * qtyValue;
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

  @override
  void dispose() {
    for (final r in _rows) {
      r.qty.dispose();
    }
    super.dispose();
  }

  // ---------- Perhitungan ----------
  double get _totalBiaya => _rows.fold(0, (s, r) => s + r.biaya);

  double? get _foodCost {
    if (widget.dasar.price <= 0 || _totalBiaya <= 0) return null;
    return _totalBiaya / widget.dasar.price * 100;
  }

  bool get _valid => _rows.isNotEmpty && _rows.every((r) => r.lengkap);

  // ---------- Aksi ----------
  void _removeRow(int i) {
    setState(() {
      final r = _rows.removeAt(i);
      r.qty.dispose();
    });
  }

  /// Membuka bottom sheet dari popup_pilihbahan.dart.
  /// Nama bahan yang sudah dipakai dikirim agar tidak bisa dipilih dua kali.
  Future<PickedBahan?> _bukaPopupPilihBahan({int? excludeIndex}) {
    final usedNames = _rows.asMap().entries
        .where((entry) =>
            entry.key != excludeIndex && entry.value.bahan != null)
        .map((entry) => entry.value.bahan!.name.toLowerCase())
        .toSet();

    return showPilihBahanSheet(
      context,
      options: daftarBahanContoh,
      usedNames: usedNames,
    );
  }

  /// Memindahkan hasil popup ke baris resep, termasuk satuan, harga,
  /// dan takaran yang sudah diisi pada langkah kedua popup.
  void _isiBarisDenganHasil(_BarisResep row, PickedBahan hasil) {
    row.bahan = BahanResep(
      name: hasil.option.name,
      unit: hasil.option.unit,
      pricePerUnit: hasil.option.unitPrice,
    );
    row.qty.text = hasil.qty.toString();
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

  void _submit() {
    if (!_valid) return;

    final menu = MenuModel(
      name: widget.dasar.name,
      category: widget.dasar.category,
      price: widget.dasar.price,
      foodCost: _foodCost,
      imageAsset: widget.dasar.imagePath,
    );

    // TODO: kirim menu + resep (_rows) ke API di sini.
    Navigator.pop(context, menu); // dikembalikan ke langkah 1 -> daftar menu
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

  static String _persen(double v) =>
      '${v.toStringAsFixed(1).replaceAll('.', ',')}%';

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
          onPressed: () => Navigator.pop(context),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
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
    final path = widget.dasar.imagePath;

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
              child: path != null
                  ? Image.file(
                      File(path),
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
                  widget.dasar.category,
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
                  width: 78,
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

  // ---------- Panel bawah: biaya + food cost + tombol ----------
  Widget _buildBottomPanel() {
    final fc = _foodCost;

    Color fcBg = _cardBg;
    Color fcFg = _fcTitle;
    if (fc != null) {
      switch (foodCostStatusOf(fc)) {
        case FoodCostStatus.aman:
          fcBg = AppColors.safeBg;
          fcFg = AppColors.green;
          break;
        case FoodCostStatus.waspada:
          fcBg = AppColors.warningStatusBg;
          fcFg = AppColors.warningStatusText;
          break;
        case FoodCostStatus.kritis:
          fcBg = AppColors.exhaustedStatusBg;
          fcFg = AppColors.red;
          break;
      }
    }

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
                'Rata-Rata Biaya per Porsi',
                style: TextStyle(fontSize: 13.5, color: AppColors.brownDark),
              ),
              Text(
                _rupiah(_totalBiaya),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: fcBg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: fcFg.withOpacity(0.5)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Food Cost',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: fcFg,
                  ),
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      fc == null ? '-' : _persen(fc),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    Text(
                      'dari ${_rupiah(widget.dasar.price)}',
                      style: TextStyle(fontSize: 11.5, color: fcFg),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: _valid ? _submit : null,
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
              child: const Text(
                'Tambahkan Menu',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
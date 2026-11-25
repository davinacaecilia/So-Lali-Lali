import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../services/cloudinary_service.dart';

import '../../constants/ingredient_options.dart';
import '../../services/ingredient_service.dart';
import '../partials/colors.dart';

/// Langkah 2 dari 2: Pengaturan Stok.
/// Data langkah 1 (nama, kategori, satuan) dikirim lewat constructor.
class TambahBahanLangkah2Page extends StatefulWidget {
  final String nama;
  final String categoryKey;
  final String unitKey; // mis. "kg" -> ditampilkan terkunci di kotak satuan
  final File? foto; // foto dari langkah 1 (opsional)

  const TambahBahanLangkah2Page({
    super.key,
    required this.nama,
    required this.categoryKey,
    required this.unitKey,
    this.foto,
  });

  @override
  State<TambahBahanLangkah2Page> createState() =>
      _TambahBahanLangkah2PageState();
}

class _TambahBahanLangkah2PageState extends State<TambahBahanLangkah2Page> {
  // ---------- Warna khusus halaman ini (diambil dari desain) ----------
  static const Color _lockedBg = AppColors.fieldLockedBg;
  static const Color _hintColor = AppColors.fieldLockedHint;

  // ---------- State ----------
  final TextEditingController _parController = TextEditingController();
  final TextEditingController _expiryController = TextEditingController();
  final TextEditingController _stokController = TextEditingController();

  String _expiryUnit = 'hari';
  final List<String> _expiryUnits = const ['hari', 'minggu', 'bulan'];

  bool _saving = false;

  UnitOption get _unit => unitByKey(widget.unitKey);

  @override
  void dispose() {
    _parController.dispose();
    _expiryController.dispose();
    _stokController.dispose();
    super.dispose();
  }

  /// "12,5" -> 12.5
  double? _toNumber(String s) => double.tryParse(s.trim().replaceAll(',', '.'));

  Future<void> _onTambah() async {
    if (_saving) return;

    final par = _toNumber(_parController.text);
    final masaSimpan = int.tryParse(_expiryController.text.trim());
    final stokText = _stokController.text.trim();
    final stok = stokText.isEmpty ? 0.0 : _toNumber(stokText);

    String? error;
    if (par == null || par <= 0) {
      error = 'Isi batas minimal dengan angka lebih dari 0';
    } else if (masaSimpan == null || masaSimpan <= 0) {
      error = 'Isi batas kadaluwarsa dengan angka lebih dari 0';
    } else if (stok == null || stok < 0) {
      error = 'Stok awal tidak valid';
    }
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      // 1) unggah foto (kalau ada) -> dapat link
      String? photoUrl;
      if (widget.foto != null) {
        photoUrl = await CloudinaryService.instance.uploadImage(widget.foto!);
      }

      // 2) simpan bahan (beserta link foto) ke Firestore
      await IngredientService.instance.addIngredient(
        name: widget.nama,
        categoryKey: widget.categoryKey,
        unitKey: widget.unitKey,
        minStock: par!,
        shelfLifeValue: masaSimpan!,
        shelfLifeUnit: _expiryUnit,
        initialStock: stok!,
        photoUrl: photoUrl,
      );
      if (!mounted) return;

      _showSuccessToast();

      // Kembali ke halaman daftar (menutup langkah 2 dan langkah 1)
      int count = 0;
      Navigator.popUntil(context, (_) => count++ >= 2);
    } on ServiceException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showSuccessToast() {
    // Ambil messenger dulu, karena halaman ini akan ditutup setelahnya.
    final messenger = ScaffoldMessenger.of(context);

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.toastBg,
          elevation: 6,
          duration: const Duration(seconds: 4),
          margin: const EdgeInsets.fromLTRB(25, 0, 25, 24),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          content: Row(
            children: [
              const Icon(Icons.check, size: 20, color: AppColors.toastCheck),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Bahan berhasil ditambahkan',
                  style: TextStyle(
                    fontFamily: kFont,
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
              ),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  messenger.hideCurrentSnackBar();
                  // TODO: buka detail bahan yang baru ditambahkan
                },
                child: const Padding(
                  padding: EdgeInsets.only(left: 12),
                  child: Text(
                    'Lihat',
                    style: TextStyle(
                      fontFamily: kFont,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.toastAction,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }

  // ======================================================
  // BUILD
  // ======================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(25, 20, 25, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStepIndicator(),
                  const SizedBox(height: 26),

                  // ----- Batas Minimal (Par Level) -----
                  _buildLabelRow('Batas Minimal (Par Level)', required: true),
                  const SizedBox(height: 8),
                  _buildFieldRow(
                    field: _buildInput(
                      controller: _parController,
                      formatters: [_decimalOnly],
                      keyboard: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),
                    unit: _buildLockedUnit(_unit.label),
                  ),
                  _buildHelper(
                    'Notifikasi stok menipis muncul saat stok di bawah angka ini.',
                  ),
                  const SizedBox(height: 26),

                  // ----- Batas Kadaluwarsa -----
                  _buildLabelRow('Batas Kadaluwarsa', required: true),
                  const SizedBox(height: 8),
                  _buildFieldRow(
                    field: _buildInput(
                      controller: _expiryController,
                      formatters: [FilteringTextInputFormatter.digitsOnly],
                      keyboard: TextInputType.number,
                    ),
                    unit: _buildExpiryDropdown(),
                  ),
                  _buildHelper('Masa simpan standar sejak barang diterima.'),
                  const SizedBox(height: 26),

                  // ----- Stok Awal -----
                  _buildLabelRow('Stok Awal', required: false),
                  const SizedBox(height: 8),
                  _buildFieldRow(
                    field: _buildInput(
                      controller: _stokController,
                      hint: '0',
                      formatters: [_decimalOnly],
                      keyboard: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),
                    unit: _buildLockedUnit(_unit.label),
                  ),
                  _buildHelper(
                    'Kosongkan jika belum ada stok. Kedaluwarsa stok awal dihitung dari hari ini + masa simpan.',
                  ),
                ],
              ),
            ),
          ),
          _buildBottom(),
        ],
      ),
    );
  }

  // Hanya angka, koma, dan titik
  static final TextInputFormatter _decimalOnly =
  FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'));

  // ======================================================
  // HEADER
  // ======================================================
  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.headerBg,
        boxShadow: [
          BoxShadow(
            color: AppColors.subtleShadow,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(38, 46, 20, 16),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.maybePop(context),
                child: const Icon(
                  Icons.arrow_back,
                  color: AppColors.textDark,
                  size: 22,
                ),
              ),
              const SizedBox(width: 45),
              const Text(
                'Tambahkan Bahan Baru',
                style: TextStyle(
                  fontFamily: kFont,
                  fontSize: 16,
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

  // ======================================================
  // STEP INDICATOR (kedua bar terisi)
  // ======================================================
  Widget _buildStepIndicator() {
    Widget bar() => Expanded(
      child: Container(
        height: 5,
        decoration: BoxDecoration(
          color: AppColors.orange,
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text(
              'Langkah 2 dari 2',
              style: TextStyle(
                fontFamily: kFont,
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.brownDark,
              ),
            ),
            Text(
              'PENGATURAN STOK',
              style: TextStyle(
                fontFamily: kFont,
                fontSize: 11,
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

  // ======================================================
  // LABEL
  // ======================================================
  Widget _buildLabelRow(String label, {required bool required}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: kFont,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
        Text(
          required ? '*Wajib' : '(Opsional)',
          style: TextStyle(
            fontFamily: kFont,
            fontSize: 11.5,
            fontWeight: required ? FontWeight.w500 : FontWeight.w400,
            color: required ? AppColors.red : AppColors.brownDark,
          ),
        ),
      ],
    );
  }

  // ======================================================
  // BARIS: [ field angka ] [ kotak satuan ]
  // ======================================================
  Widget _buildFieldRow({required Widget field, required Widget unit}) {
    return Row(
      children: [
        Expanded(child: field),
        const SizedBox(width: 9),
        unit,
      ],
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required List<TextInputFormatter> formatters,
    required TextInputType keyboard,
    String? hint,
    String? prefix,
  }) {
    return SizedBox(
      height: 56,
      child: TextField(
        controller: controller,
        keyboardType: keyboard,
        inputFormatters: formatters,
        style: const TextStyle(
          fontFamily: kFont,
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.textDark,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
            fontFamily: kFont,
            fontSize: 16,
            color: _hintColor,
          ),
          prefixIcon: prefix == null
              ? null
              : Padding(
            padding: const EdgeInsets.only(left: 16, right: 12),
            child: Text(
              prefix,
              style: const TextStyle(
                fontFamily: kFont,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.brownDark,
              ),
            ),
          ),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 0,
            minHeight: 0,
          ),
          contentPadding: EdgeInsets.fromLTRB(
            prefix == null ? 16 : 0,
            16,
            16,
            16,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.brown, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.brown, width: 1.5),
          ),
        ),
      ),
    );
  }

  // ---------- Kotak satuan terkunci (mis. "kg 🔒") ----------
  Widget _buildLockedUnit(String text) {
    return Container(
      width: 101,
      height: 56,
      decoration: BoxDecoration(
        color: _lockedBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.brown, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            text,
            style: const TextStyle(
              fontFamily: kFont,
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: AppColors.brown,
            ),
          ),
          const SizedBox(width: 6),
          const Icon(Icons.lock_outline, size: 15, color: AppColors.brown),
        ],
      ),
    );
  }

  // ---------- Dropdown satuan waktu (hari / minggu / bulan) ----------
  Widget _buildExpiryDropdown() {
    return Container(
      width: 101,
      height: 56,
      padding: const EdgeInsets.only(left: 14, right: 8),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.brown, width: 1),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _expiryUnit,
          isExpanded: true,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.brownDark,
            size: 20,
          ),
          style: const TextStyle(
            fontFamily: kFont,
            fontSize: 15,
            color: AppColors.textDark,
          ),
          items: _expiryUnits
              .map((e) => DropdownMenuItem<String>(value: e, child: Text(e)))
              .toList(),
          onChanged: (v) {
            if (v != null) setState(() => _expiryUnit = v);
          },
        ),
      ),
    );
  }

  // ---------- Teks bantuan di bawah field ----------
  Widget _buildHelper(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: kFont,
          fontSize: 13,
          height: 1.3,
          color: AppColors.brown,
        ),
      ),
    );
  }

  // ======================================================
  // TOMBOL BAWAH
  // ======================================================
  Widget _buildBottom() {
    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.fromLTRB(25, 8, 25, 40),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: 58,
          child: ElevatedButton(
            onPressed: _saving ? null : _onTambah,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.orange,
              disabledBackgroundColor: AppColors.orange.withOpacity(0.6),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
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
              'Tambahkan Bahan',
              style: TextStyle(
                fontFamily: kFont,
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
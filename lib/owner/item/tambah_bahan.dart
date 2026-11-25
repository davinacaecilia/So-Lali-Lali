import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../constants/ingredient_options.dart';
import '../partials/colors.dart';
import 'pilih_satuan.dart';
import 'tambah_bahan(2).dart';

enum _FotoAksi { kamera, galeri, hapus }

class TambahBahanBaruPage extends StatefulWidget {
  const TambahBahanBaruPage({super.key});

  @override
  State<TambahBahanBaruPage> createState() => _TambahBahanBaruPageState();
}

class _TambahBahanBaruPageState extends State<TambahBahanBaruPage> {
  // ---------- Warna khusus halaman ini (diambil dari desain) ----------
  static const Color _hintColor = AppColors.mutedText;
  static const Color _btnBg = AppColors.buttonBg;
  static const Color _btnText = AppColors.buttonText;
  static const Color _progressInactive = AppColors.buttonBg;
  static const Color _optionalText = AppColors.optionalText;
  static const Color _footerText = AppColors.optionalText;
  static const Color _fotoHint = AppColors.photoHint;

  static const int _maxFotoBytes = 5 * 1024 * 1024; // 5 MB

  // ---------- State ----------
  final TextEditingController _namaController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  String? _kategori; // kunci kategori, mis. 'bahan_kering'
  String? _unitKey; // kunci satuan, mis. 'kg' (dari sheet)
  File? _foto; // foto terpilih (belum diunggah; dipakai di Tahap 2B/2C)

  UnitOption? get _unit => _unitKey == null ? null : unitByKey(_unitKey!);

  @override
  void dispose() {
    _namaController.dispose();
    super.dispose();
  }

  Future<void> _pilihSatuan() async {
    final hasil = await showPilihSatuanSheet(context, current: _unitKey);
    if (hasil != null) setState(() => _unitKey = hasil);
  }

  // ---------- Foto ----------
  Future<void> _pilihFoto() async {
    final aksi = await showModalBottomSheet<_FotoAksi>(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.brown.withOpacity(0.3),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(
                Icons.photo_camera_outlined,
                color: AppColors.brownDark,
              ),
              title: const Text(
                'Ambil foto',
                style: TextStyle(fontFamily: kFont, fontSize: 15),
              ),
              onTap: () => Navigator.pop(ctx, _FotoAksi.kamera),
            ),
            ListTile(
              leading: const Icon(
                Icons.photo_library_outlined,
                color: AppColors.brownDark,
              ),
              title: const Text(
                'Pilih dari galeri',
                style: TextStyle(fontFamily: kFont, fontSize: 15),
              ),
              onTap: () => Navigator.pop(ctx, _FotoAksi.galeri),
            ),
            if (_foto != null)
              ListTile(
                leading: const Icon(Icons.delete_outline, color: AppColors.red),
                title: const Text(
                  'Hapus foto',
                  style: TextStyle(
                    fontFamily: kFont,
                    fontSize: 15,
                    color: AppColors.red,
                  ),
                ),
                onTap: () => Navigator.pop(ctx, _FotoAksi.hapus),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );

    switch (aksi) {
      case _FotoAksi.kamera:
        await _ambilFoto(ImageSource.camera);
        break;
      case _FotoAksi.galeri:
        await _ambilFoto(ImageSource.gallery);
        break;
      case _FotoAksi.hapus:
        setState(() => _foto = null);
        break;
      case null:
        break; // menu ditutup tanpa memilih
    }
  }

  Future<void> _ambilFoto(ImageSource sumber) async {
    try {
      final picked = await _picker.pickImage(
        source: sumber,
        maxWidth: 1280,
        maxHeight: 1280,
        imageQuality: 80,
      );
      if (picked == null) return; // dibatalkan user

      final file = File(picked.path);
      if (await file.length() > _maxFotoBytes) {
        _pesan('Ukuran foto melebihi 5 MB');
        return;
      }
      if (!mounted) return;
      setState(() => _foto = file);
    } catch (e) {
      debugPrint('pickImage error: $e');
      _pesan('Tidak dapat mengakses kamera atau galeri');
    }
  }

  void _pesan(String teks) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(teks)),
    );
  }

  void _onBerikutnya() {
    final nama = _namaController.text.trim();

    // Validasi sisi UI: field wajib harus terisi
    if (nama.isEmpty || _kategori == null || _unitKey == null) {
      _pesan('Lengkapi nama, kategori, dan satuan');
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TambahBahanLangkah2Page(
          nama: nama,
          categoryKey: _kategori!,
          unitKey: _unitKey!,
          foto: _foto,
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
              padding: const EdgeInsets.fromLTRB(25, 20, 25, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStepIndicator(),
                  const SizedBox(height: 26),

                  // ----- Nama Bahan -----
                  _buildLabelRow('Nama Bahan', required: true),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _namaController,
                    hint: 'Contoh: Tepung Terigu Protein Tinggi',
                  ),
                  const SizedBox(height: 18),

                  // ----- Kategori Bahan -----
                  _buildLabelRow('Kategori Bahan', required: true),
                  const SizedBox(height: 10),
                  _buildDropdown(
                    hint: 'Pilih kategori',
                    value: _kategori,
                    items: kCategories,
                    onChanged: (v) => setState(() => _kategori = v),
                  ),
                  const SizedBox(height: 20),

                  // ----- Satuan -----
                  _buildLabelRow('Satuan', required: true),
                  const SizedBox(height: 8),
                  _buildSatuanField(),
                  const SizedBox(height: 18),

                  // ----- Foto -----
                  _buildLabelRow('Foto Bahan', required: false),
                  const SizedBox(height: 8),
                  _buildFotoBox(),
                  const SizedBox(height: 62),
                ],
              ),
            ),
          ),
          _buildBottom(),
        ],
      ),
    );
  }

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
              const SizedBox(width: 34),
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
  // STEP INDICATOR
  // ======================================================
  Widget _buildStepIndicator() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text(
              'Langkah 1 dari 2',
              style: TextStyle(
                fontFamily: kFont,
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.brownDark,
              ),
            ),
            Text(
              'INFORMASI DASAR',
              style: TextStyle(
                fontFamily: kFont,
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.6,
                color: AppColors.mutedBrown,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Container(
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.orange,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                height: 5,
                decoration: BoxDecoration(
                  color: _progressInactive,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
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
          required ? '*Wajib' : 'Opsional',
          style: TextStyle(
            fontFamily: kFont,
            fontSize: 11.5,
            fontWeight: required ? FontWeight.w500 : FontWeight.w400,
            color: required ? AppColors.red : _optionalText,
          ),
        ),
      ],
    );
  }

  // ======================================================
  // TEXT FIELD (Nama Bahan)
  // ======================================================
  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
  }) {
    return SizedBox(
      height: 56,
      child: TextField(
        controller: controller,
        style: const TextStyle(
          fontFamily: kFont,
          fontSize: 14,
          color: AppColors.textDark,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
            fontFamily: kFont,
            fontSize: 14,
            color: _hintColor,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
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

  // ======================================================
  // DROPDOWN KATEGORI
  // ======================================================
  Widget _buildDropdown({
    required String hint,
    required String? value,
    required List<CategoryOption> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.brown, width: 1),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          hint: Text(
            hint,
            style: const TextStyle(
              fontFamily: kFont,
              fontSize: 14,
              color: _hintColor,
            ),
          ),
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.brownDark,
            size: 24,
          ),
          style: const TextStyle(
            fontFamily: kFont,
            fontSize: 14,
            color: AppColors.textDark,
          ),
          items: items
              .map(
                (e) => DropdownMenuItem<String>(
              value: e.key,
              child: Text(e.label),
            ),
          )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  // ======================================================
  // SATUAN (membuka bottom sheet "Pilih Satuan")
  // ======================================================
  Widget _buildSatuanField() {
    return GestureDetector(
      onTap: _pilihSatuan,
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.brown, width: 1),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                _unit?.label ?? 'Pilih satuan (kg, liter, butir, pcs)',
                style: TextStyle(
                  fontFamily: kFont,
                  fontSize: 14,
                  color: _unit == null ? _hintColor : AppColors.textDark,
                ),
              ),
            ),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppColors.brownDark,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  // ======================================================
  // FOTO (kosong = kotak ajakan, terisi = pratinjau)
  // ======================================================
  Widget _buildFotoBox() {
    return GestureDetector(
      onTap: _pilihFoto,
      child: Container(
        width: double.infinity,
        height: 156,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.brown, width: 1),
        ),
        child: _foto == null ? _buildFotoKosong() : _buildFotoPratinjau(),
      ),
    );
  }

  Widget _buildFotoKosong() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.iconBox,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.photo_camera_outlined,
            color: AppColors.brownDark,
            size: 24,
          ),
        ),
        const SizedBox(height: 14),
        const Text(
          'Ambil foto atau pilih dari galeri',
          style: TextStyle(
            fontFamily: kFont,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Maks. 5 MB',
          style: TextStyle(
            fontFamily: kFont,
            fontSize: 12.5,
            color: _fotoHint,
          ),
        ),
      ],
    );
  }

  Widget _buildFotoPratinjau() {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.file(_foto!, fit: BoxFit.cover),
        Positioned(
          top: 8,
          right: 8,
          child: Container(
            width: 34,
            height: 34,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.edit_outlined,
              size: 18,
              color: AppColors.brownDark,
            ),
          ),
        ),
      ],
    );
  }

  // ======================================================
  // BAGIAN BAWAH (tombol + catatan)
  // ======================================================
  Widget _buildBottom() {
    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.fromLTRB(25, 0, 25, 24),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _onBerikutnya,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _btnBg,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      'Berikutnya',
                      style: TextStyle(
                        fontFamily: kFont,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: _btnText,
                      ),
                    ),
                    SizedBox(width: 6),
                    Icon(Icons.arrow_forward, size: 18, color: _btnText),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'Informasi stok & tanggal kedaluwarsa diatur di langkah ke-2',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: kFont,
                fontSize: 11,
                color: _footerText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
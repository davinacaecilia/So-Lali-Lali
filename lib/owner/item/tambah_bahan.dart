import 'package:flutter/material.dart';

import '../partials/colors.dart';
import 'pilih_satuan.dart';
import 'tambah_bahan(2).dart';

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

  // ---------- State ----------
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _kategoriBaruController = TextEditingController();

  bool _kategoriBaru = false; // false = pilih yang sudah ada, true = ketik baru
  String? _kategori;
  String? _satuan;

  // Data contoh (nanti diganti data dari backend/API)
  final List<String> _kategoriList = const [
    'Bahan Kering',
    'Minuman & Biji Kopi',
    'Susu & Olahan',
    'Protein & Daging',
    'Bumbu & Rempah',
  ];

  /// Nilai kategori final yang akan disimpan, apapun modenya.
  String? get kategoriTerpilih {
    if (_kategoriBaru) {
      final v = _kategoriBaruController.text.trim();
      return v.isEmpty ? null : v;
    }
    return _kategori;
  }

  @override
  void dispose() {
    _namaController.dispose();
    _kategoriBaruController.dispose();
    super.dispose();
  }

  Future<void> _pilihSatuan() async {
    final hasil = await showPilihSatuanSheet(context, current: _satuan);
    if (hasil != null) setState(() => _satuan = hasil);
  }

  void _onBerikutnya() {
    final nama = _namaController.text.trim();
    final kategori = kategoriTerpilih;

    // Validasi sisi UI: field wajib harus terisi
    if (nama.isEmpty || kategori == null || _satuan == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lengkapi nama, kategori, dan satuan')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TambahBahanLangkah2Page(
          nama: nama,
          kategori: kategori,
          satuan: _satuan!,
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
                  _buildKategoriModeRow(),
                  const SizedBox(height: 10),
                  if (_kategoriBaru)
                    _buildTextField(
                      controller: _kategoriBaruController,
                      hint: 'Tulis nama kategori baru',
                    )
                  else
                    _buildDropdown(
                      hint: 'Pilih kategori',
                      value: _kategori,
                      items: _kategoriList,
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
  // PILIHAN MODE KATEGORI (radio)
  // ======================================================
  Widget _buildKategoriModeRow() {
    return Row(
      children: [
        _buildRadioOption(
          label: 'Kategori yang Sudah Ada',
          selected: !_kategoriBaru,
          onTap: () => setState(() => _kategoriBaru = false),
        ),
        const SizedBox(width: 36),
        _buildRadioOption(
          label: 'Kategori Baru',
          selected: _kategoriBaru,
          onTap: () => setState(() => _kategoriBaru = true),
        ),
      ],
    );
  }

  Widget _buildRadioOption({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: selected ? AppColors.orange : AppColors.background,
              border: Border.all(color: AppColors.orange, width: 1.5),
            ),
            child: selected
                ? Center(
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.brownDark,
                      ),
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontFamily: kFont,
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.brownDark,
            ),
          ),
        ],
      ),
    );
  }

  // ======================================================
  // TEXT FIELD (dipakai Nama Bahan & Kategori Baru)
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
  // DROPDOWN (Kategori yang sudah ada)
  // ======================================================
  Widget _buildDropdown({
    required String hint,
    required String? value,
    required List<String> items,
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
              .map((e) => DropdownMenuItem<String>(value: e, child: Text(e)))
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
                _satuan ?? 'Pilih satuan (kg, liter, butir, pcs)',
                style: TextStyle(
                  fontFamily: kFont,
                  fontSize: 14,
                  color: _satuan == null ? _hintColor : AppColors.textDark,
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
  // FOTO
  // ======================================================
  Widget _buildFotoBox() {
    return GestureDetector(
      onTap: () {
        // TODO: ambil foto / pilih dari galeri
      },
      child: Container(
        width: double.infinity,
        height: 156,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.brown, width: 1),
        ),
        child: Column(
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
        ),
      ),
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

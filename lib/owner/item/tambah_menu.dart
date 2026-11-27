import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../../constants/menu_options.dart';
import '../partials/colors.dart';
import 'tambah_menu(2).dart';

/// Data dari langkah 1 (Informasi Dasar), dikirim ke langkah 2.
class MenuDasar {
  final String name;
  final String categoryKey; // kunci kategori, mis. "minuman_kopi"
  final int price;
  final File? foto; // foto terpilih (diunggah di langkah 2)

  const MenuDasar({
    required this.name,
    required this.categoryKey,
    required this.price,
    this.foto,
  });
}

enum _FotoAksi { kamera, galeri, hapus }

class TambahMenuBaruPage extends StatefulWidget {
  const TambahMenuBaruPage({super.key});

  @override
  State<TambahMenuBaruPage> createState() => _TambahMenuBaruPageState();
}

class _TambahMenuBaruPageState extends State<TambahMenuBaruPage> {
  // Warna khusus halaman ini (dari desain).
  static const _headerBg = Color(0xFFFBF7EE);
  static const _border = Color(0xFF7A4A12);
  static const _stepActive = Color(0xFFE8A22B);
  static const _stepIdle = Color(0xFFFBDCC3);
  static const _label = Color(0xFF3A2208);
  static const _required = Color(0xFFD0021B);
  static const _prefixBg = Color(0xFFF3E8D6);
  static const _btnDisabled = Color(0xFFFBDCC3);
  static const _btnDisabledText = Color(0xFF8A3B12);

  static const int _maxFotoBytes = 5 * 1024 * 1024; // 5 MB

  final _nameCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  String? _selectedCategory; // kunci kategori
  File? _foto;

  int get _price => int.tryParse(_priceCtrl.text.replaceAll('.', '')) ?? 0;

  bool get _valid =>
      _nameCtrl.text.trim().isNotEmpty &&
          _price > 0 &&
          _selectedCategory != null;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  // ---------- Foto ----------
  Future<void> _pickImage() async {
    final aksi = await showModalBottomSheet<_FotoAksi>(
      context: context,
      backgroundColor: Colors.white,
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
              title: const Text('Ambil foto'),
              onTap: () => Navigator.pop(ctx, _FotoAksi.kamera),
            ),
            ListTile(
              leading: const Icon(
                Icons.photo_library_outlined,
                color: AppColors.brownDark,
              ),
              title: const Text('Pilih dari galeri'),
              onTap: () => Navigator.pop(ctx, _FotoAksi.galeri),
            ),
            if (_foto != null)
              ListTile(
                leading: const Icon(Icons.delete_outline, color: AppColors.red),
                title: const Text(
                  'Hapus foto',
                  style: TextStyle(color: AppColors.red),
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
        break;
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
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(teks)));
  }

  // ---------- Lanjut ke langkah 2 ----------
  Future<void> _next() async {
    if (!_valid) return;

    final data = MenuDasar(
      name: _nameCtrl.text.trim(),
      categoryKey: _selectedCategory!,
      price: _price,
      foto: _foto,
    );

    // Langkah 2 menyimpan menu ke Firestore, lalu mengembalikan true.
    final hasil = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => TambahMenuResepPage(dasar: data)),
    );

    // Menu tersimpan -> tutup langkah 1, kembali ke daftar menu.
    if (hasil == true && mounted) Navigator.pop(context, true);
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
                padding: const EdgeInsets.fromLTRB(25, 20, 25, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStepper(),
                    const SizedBox(height: 28),

                    // ----- Nama Menu -----
                    _buildLabel('Nama Menu', required: true),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _nameCtrl,
                      hint: 'Contoh: Kopi Susu Gula Aren',
                      textCapitalization: TextCapitalization.words,
                    ),
                    const SizedBox(height: 22),

                    // ----- Kategori -----
                    _buildLabel('Kategori Menu', required: true),
                    const SizedBox(height: 8),
                    _buildDropdown(),
                    const SizedBox(height: 22),

                    // ----- Harga -----
                    _buildLabel('Harga (Rp)', required: true),
                    const SizedBox(height: 8),
                    _buildPriceField(),
                    const SizedBox(height: 22),

                    // ----- Foto -----
                    _buildLabel('Foto Menu', optional: true),
                    const SizedBox(height: 8),
                    _buildPhotoBox(),
                  ],
                ),
              ),
            ),

            // ----- Tombol bawah -----
            Padding(
              padding: const EdgeInsets.fromLTRB(25, 8, 25, 20),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _valid ? _next : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.orangeAccent,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: _btnDisabled,
                        disabledForegroundColor: _btnDisabledText,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Berikutnya',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(width: 6),
                          Icon(Icons.arrow_forward, size: 18),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Resep diatur di langkah ke-2',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: AppColors.brownDark),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =====================================================
  // KOMPONEN
  // =====================================================
  Widget _buildStepper() {
    Widget bar(Color c) => Expanded(
      child: Container(
        height: 5,
        decoration: BoxDecoration(
          color: c,
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
              'Langkah 1 dari 2',
              style: TextStyle(fontSize: 13.5, color: AppColors.brownDark),
            ),
            Text(
              'INFORMASI DASAR',
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
        Row(children: [bar(_stepActive), const SizedBox(width: 8), bar(_stepIdle)]),
      ],
    );
  }

  Widget _buildLabel(
      String text, {
        bool required = false,
        bool optional = false,
      }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          text,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: _label,
          ),
        ),
        if (required)
          const Text(
            '*Wajib',
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: _required,
            ),
          ),
        if (optional)
          const Text(
            'Opsional',
            style: TextStyle(fontSize: 12.5, color: AppColors.subtitle),
          ),
      ],
    );
  }

  OutlineInputBorder _outline() => OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide: const BorderSide(color: _border, width: 1),
  );

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return SizedBox(
      height: 54,
      child: TextField(
        controller: controller,
        textCapitalization: textCapitalization,
        onChanged: (_) => setState(() {}),
        style: const TextStyle(fontSize: 15, color: AppColors.textDark),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(fontSize: 15, color: AppColors.fieldHint),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          enabledBorder: _outline(),
          focusedBorder: _outline(),
        ),
      ),
    );
  }

  Widget _buildDropdown() {
    return Container(
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedCategory,
          isExpanded: true,
          hint: const Text(
            'Pilih kategori',
            style: TextStyle(fontSize: 15, color: AppColors.fieldHint),
          ),
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: _border),
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(10),
          style: const TextStyle(fontSize: 15, color: AppColors.textDark),
          items: kMenuCategories
              .map((c) => DropdownMenuItem(value: c.key, child: Text(c.label)))
              .toList(),
          onChanged: (v) => setState(() => _selectedCategory = v),
        ),
      ),
    );
  }

  Widget _buildPriceField() {
    return Container(
      height: 54,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          Container(
            width: 48,
            alignment: Alignment.center,
            color: _prefixBg,
            child: const Text(
              'Rp',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.brownDark,
              ),
            ),
          ),
          Expanded(
            child: TextField(
              controller: _priceCtrl,
              keyboardType: TextInputType.number,
              inputFormatters: [_RibuanFormatter()],
              onChanged: (_) => setState(() {}),
              style: const TextStyle(fontSize: 15, color: AppColors.textDark),
              decoration: const InputDecoration(
                hintText: '0',
                hintStyle: TextStyle(fontSize: 15, color: AppColors.fieldHint),
                contentPadding: EdgeInsets.symmetric(horizontal: 16),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoBox() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        height: 155,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _border),
        ),
        clipBehavior: Clip.antiAlias,
        child: _foto != null
            ? Stack(
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
        )
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.peach,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.photo_camera_outlined,
                color: AppColors.brownDark,
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'Ambil foto atau pilih dari galeri',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: _label,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Maks. 5 MB',
              style: TextStyle(fontSize: 13, color: AppColors.brownDark),
            ),
          ],
        ),
      ),
    );
  }
}

/// Format angka dengan titik ribuan: 28000 -> 28.000
class _RibuanFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return const TextEditingValue();

    final buf = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buf.write('.');
      buf.write(digits[i]);
    }
    final text = buf.toString();
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
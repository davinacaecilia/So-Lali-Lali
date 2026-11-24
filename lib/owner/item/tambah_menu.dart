import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../partials/colors.dart';
import 'filter_menu.dart';
import 'tambah_menu(2).dart';

/// Data dari langkah 1 (Informasi Dasar), dikirim ke langkah 2.
class MenuDasar {
  final String name;
  final String category;
  final bool isNewCategory;
  final int price;
  final String? imagePath;

  const MenuDasar({
    required this.name,
    required this.category,
    required this.isNewCategory,
    required this.price,
    this.imagePath,
  });
}

class TambahMenuBaruPage extends StatefulWidget {
  const TambahMenuBaruPage({super.key});

  @override
  State<TambahMenuBaruPage> createState() => _TambahMenuBaruPageState();
}

class _TambahMenuBaruPageState extends State<TambahMenuBaruPage> {
  // Warna khusus halaman ini (dari desain).
  // Pindahkan ke AppColors jika sudah ada padanannya.
  static const _headerBg = Color(0xFFFBF7EE);
  static const _border = Color(0xFF7A4A12);
  static const _stepActive = Color(0xFFE8A22B);
  static const _stepIdle = Color(0xFFFBDCC3);
  static const _label = Color(0xFF3A2208);
  static const _required = Color(0xFFD0021B);
  static const _prefixBg = Color(0xFFF3E8D6);
  static const _btnDisabled = Color(0xFFFBDCC3);
  static const _btnDisabledText = Color(0xFF8A3B12);

  final _nameCtrl = TextEditingController();
  final _newCategoryCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();

  bool _isNewCategory = false;
  String? _selectedCategory;
  String? _imagePath;

  final List<String> _categories = kKategoriMenuFilter.keys.toList();

  int get _price =>
      int.tryParse(_priceCtrl.text.replaceAll('.', '')) ?? 0;

  bool get _valid {
    if (_nameCtrl.text.trim().isEmpty) return false;
    if (_price <= 0) return false;
    if (_isNewCategory) return _newCategoryCtrl.text.trim().isNotEmpty;
    return _selectedCategory != null;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _newCategoryCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  void _pickImage() {
    // TODO: pakai package image_picker (kamera / galeri, maks. 5 MB),
    // lalu setState(() => _imagePath = file.path);
  }

  Future<void> _next() async {
  if (!_valid) return;

  final data = MenuDasar(
    name: _nameCtrl.text.trim(),
    category: _isNewCategory
        ? _newCategoryCtrl.text.trim()
        : _selectedCategory!,
    isNewCategory: _isNewCategory,
    price: _price,
    imagePath: _imagePath,
  );

  // Langkah 2 mengembalikan MenuModel saat "Tambahkan Menu" ditekan.
  // Tipe dibuat Object? supaya file ini tidak perlu import MenuModel.
  final hasil = await Navigator.push<Object?>(
    context,
    MaterialPageRoute(builder: (_) => TambahMenuResepPage(dasar: data)),
  );

  // Teruskan hasilnya ke halaman daftar, lalu tutup langkah 1.
  if (hasil != null && mounted) Navigator.pop(context, hasil);
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
                    _buildCategoryToggle(),
                    const SizedBox(height: 10),
                    if (_isNewCategory)
                      _buildTextField(
                        controller: _newCategoryCtrl,
                        hint: 'Nama kategori baru',
                        textCapitalization: TextCapitalization.words,
                      )
                    else
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
                    'Resep dan perhitungan food cost diatur di langkah ke-2',
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

  // ----- Radio: kategori yang sudah ada / baru -----
  Widget _buildCategoryToggle() {
    Widget option(String label, bool value) {
      final selected = _isNewCategory == value;
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => setState(() => _isNewCategory = value),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? AppColors.orangeAccent : _stepActive,
                  width: 1.5,
                ),
              ),
              child: selected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.orangeAccent,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(fontSize: 14, color: AppColors.textDark),
            ),
          ],
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        option('Kategori yang Sudah Ada', false),
        option('Kategori Baru', true),
      ],
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
          items: _categories
              .map((c) => DropdownMenuItem(value: c, child: Text(c)))
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
        child: _imagePath != null
            ? Stack(
                fit: StackFit.expand,
                children: [
                  // Ganti ke Image.file(File(_imagePath!)) setelah image_picker dipasang.
                  Container(color: AppColors.peach),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () => setState(() => _imagePath = null),
                      child: const CircleAvatar(
                        radius: 14,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.close, size: 16),
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
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'daftar_menu.dart';
import 'filter_menu.dart';

// =====================================================
// HALAMAN EDIT INFORMASI MENU
// Dibuka dari ikon pensil "Detail Menu" di InformasiMenuPage.
// Saat disimpan, mengembalikan MenuModel baru lewat Navigator.pop.
// =====================================================
class EditDetailMenuPage extends StatefulWidget {
  final MenuModel menu;

  const EditDetailMenuPage({super.key, required this.menu});

  @override
  State<EditDetailMenuPage> createState() => _EditDetailMenuPageState();
}

class _EditDetailMenuPageState extends State<EditDetailMenuPage> {
  // ---------- Warna (disesuaikan dengan desain) ----------
  static const _headerBg = Color(0xFFFBF7EE);
  static const _textDark = Color(0xFF1E1408);
  static const _brown = Color(0xFF8A4B14);
  static const _beige = Color(0xFFF3E8D6);
  static const _orange = Color(0xFFE59E2C);
  static const _red = Color(0xFFC0191F);
  static const _peachIcon = Color(0xFFFBD9B8);
  static const _recipeBarBg = Color(0xFFFFEFE4);

  late final TextEditingController _nameCtrl;
  late final TextEditingController _priceCtrl;
  final TextEditingController _newCategoryCtrl = TextEditingController();

  late List<String> _categories;
  late String _selectedCategory;
  bool _useNewCategory = false;

  @override
  void initState() {
    super.initState();
    final m = widget.menu;
    _nameCtrl = TextEditingController(text: m.name);
    _priceCtrl = TextEditingController(text: _fmtThousand(m.price));

    // Daftar kategori diambil dari filter_menu.dart
    _categories = kKategoriMenuFilter.values.toSet().toList();
    if (!_categories.contains(m.category)) _categories.insert(0, m.category);
    _selectedCategory = m.category;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    _newCategoryCtrl.dispose();
    super.dispose();
  }

  /// 22000 -> "22.000"
  static String _fmtThousand(int v) {
    final s = v.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return buf.toString();
  }

  // ------------------------------------------------------------
  // AKSI
  // ------------------------------------------------------------
  void _pickImage() {
    // TODO: pakai package image_picker (kamera / galeri, maks. 5 MB)
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg)));
  }

  void _save() {
    final name = _nameCtrl.text.trim();
    final price = int.tryParse(_priceCtrl.text.replaceAll('.', '')) ?? 0;
    final category = _useNewCategory
        ? _newCategoryCtrl.text.trim()
        : _selectedCategory;

    if (name.isEmpty) return _showError('Nama menu wajib diisi');
    if (category.isEmpty) return _showError('Kategori menu wajib diisi');
    if (price <= 0) return _showError('Harga wajib diisi');

    final m = widget.menu;
    // TODO: kirim perubahan ke API
    Navigator.pop(
      context,
      MenuModel(
        id: m.id,
        name: name,
        category: category,
        price: price,
        foodCost: m.foodCost,
        recipe: m.recipe,
        imageAsset: m.imageAsset,
        icon: m.icon,
      ),
    );
  }

  Future<void> _confirmDelete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus menu?'),
        content: Text('Menu "${widget.menu.name}" akan dihapus permanen.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus', style: TextStyle(color: _red)),
          ),
        ],
      ),
    );

    if (ok == true && mounted) {
      // TODO: panggil API hapus menu
      // Tutup halaman edit + halaman informasi, kembali ke daftar menu.
      int n = 0;
      Navigator.of(context).popUntil((_) => n++ >= 2);
    }
  }

  void _openRecipe() {
    // TODO: buka halaman "Atur Rincian Resep & Bahan"
  }

  // ------------------------------------------------------------
  // BUILD
  // ------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(25, 19, 25, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPhotoPicker(),
                  const SizedBox(height: 22),
                  _buildLabel('Nama Menu'),
                  const SizedBox(height: 8),
                  _buildNameField(),
                  const SizedBox(height: 22),
                  _buildLabel('Kategori Menu'),
                  const SizedBox(height: 8),
                  _buildCategoryMode(),
                  const SizedBox(height: 10),
                  _useNewCategory ? _buildNewCategoryField() : _buildDropdown(),
                  const SizedBox(height: 22),
                  _buildLabel('Harga (Rp)'),
                  const SizedBox(height: 8),
                  _buildPriceField(),
                  const SizedBox(height: 18),
                  _buildDeleteButton(),
                  const SizedBox(height: 20),
                  _buildRecipeBar(),
                ],
              ),
            ),
          ),
          _buildSaveButton(),
        ],
      ),
    );
  }

  // ---------- Header ----------
  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: _headerBg,
        boxShadow: [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 70,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 14),
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.arrow_back,
                      size: 22,
                      color: _textDark,
                    ),
                  ),
                ),
              ),
              const Text(
                'Edit Informasi Menu',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: _textDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------- Area foto ----------
  Widget _buildPhotoPicker() {
    final img = widget.menu.imageAsset;

    return InkWell(
      onTap: _pickImage,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: double.infinity,
        height: 166,
        decoration: BoxDecoration(
          color: _beige,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: _brown, width: 1),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(7),
          child: Stack(
            children: [
              // foto lama, dibuat pudar
              if (img != null)
                Positioned.fill(
                  child: Opacity(
                    opacity: 0.35,
                    child: Image.asset(
                      img,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const SizedBox(),
                    ),
                  ),
                ),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: _peachIcon,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.photo_camera_outlined,
                        size: 24,
                        color: _brown,
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Ambil foto atau pilih dari galeri',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: _textDark,
                      ),
                    ),
                    const SizedBox(height: 3),
                    const Text(
                      'Maks. 5 MB',
                      style: TextStyle(fontSize: 12.5, color: _brown),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------- Label + "*Wajib" ----------
  Widget _buildLabel(String text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          text,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: _textDark,
          ),
        ),
        const Text(
          '*Wajib',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: _red,
          ),
        ),
      ],
    );
  }

  OutlineInputBorder _border() => OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: const BorderSide(color: _brown, width: 1),
  );

  // ---------- Nama ----------
  Widget _buildNameField() {
    return SizedBox(
      height: 56,
      child: TextField(
        controller: _nameCtrl,
        textCapitalization: TextCapitalization.words,
        style: const TextStyle(
          fontSize: 13.5,
          fontWeight: FontWeight.w700,
          color: _textDark,
        ),
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 15),
          enabledBorder: _border(),
          focusedBorder: _border(),
        ),
      ),
    );
  }

  // ---------- Pilihan kategori lama / baru ----------
  Widget _buildCategoryMode() {
    return Row(
      children: [
        _radio('Kategori yang Sudah Ada', !_useNewCategory, () {
          setState(() => _useNewCategory = false);
        }),
        const Spacer(),
        _radio('Kategori Baru', _useNewCategory, () {
          setState(() => _useNewCategory = true);
        }),
      ],
    );
  }

  Widget _radio(String label, bool selected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
            size: 18,
            color: _orange,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 13, color: _textDark),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown() {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _brown, width: 1),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedCategory,
          isExpanded: true,
          borderRadius: BorderRadius.circular(8),
          dropdownColor: Colors.white,
          icon: const Icon(Icons.keyboard_arrow_down, color: _brown),
          style: const TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
            color: _textDark,
          ),
          items: _categories
              .map((c) => DropdownMenuItem(value: c, child: Text(c)))
              .toList(),
          onChanged: (v) {
            if (v != null) setState(() => _selectedCategory = v);
          },
        ),
      ),
    );
  }

  Widget _buildNewCategoryField() {
    return SizedBox(
      height: 56,
      child: TextField(
        controller: _newCategoryCtrl,
        textCapitalization: TextCapitalization.words,
        style: const TextStyle(
          fontSize: 13.5,
          fontWeight: FontWeight.w700,
          color: _textDark,
        ),
        decoration: InputDecoration(
          hintText: 'Nama kategori baru',
          hintStyle: const TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w400,
            color: Color(0xFF9A8F80),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 15),
          enabledBorder: _border(),
          focusedBorder: _border(),
        ),
      ),
    );
  }

  // ---------- Harga ----------
  Widget _buildPriceField() {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _brown, width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(7),
        child: Row(
          children: [
            Container(
              width: 47,
              height: double.infinity,
              decoration: const BoxDecoration(
                color: _beige,
                border: Border(right: BorderSide(color: _brown, width: 1)),
              ),
              alignment: Alignment.center,
              child: const Text(
                'Rp',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: _brown,
                ),
              ),
            ),
            Expanded(
              child: TextField(
                controller: _priceCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [_ThousandFormatter()],
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: _textDark,
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 17),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- Hapus menu ----------
  Widget _buildDeleteButton() {
    return Align(
      alignment: Alignment.centerLeft,
      child: InkWell(
        onTap: _confirmDelete,
        borderRadius: BorderRadius.circular(6),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.delete_outline, size: 18, color: _red),
              SizedBox(width: 6),
              Text(
                'Hapus menu',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: _red,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------- Atur Rincian Resep & Bahan ----------
  Widget _buildRecipeBar() {
    return Material(
      color: _recipeBarBg,
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        borderRadius: BorderRadius.circular(6),
        onTap: _openRecipe,
        child: const SizedBox(
          height: 50,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Atur Rincian Resep & Bahan',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: _brown,
                  ),
                ),
                Icon(Icons.chevron_right, size: 20, color: _textDark),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------- Tombol simpan ----------
  Widget _buildSaveButton() {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(25, 8, 25, 22),
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            onPressed: _save,
            style: ElevatedButton.styleFrom(
              backgroundColor: _orange,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            icon: const Icon(Icons.check_circle_outline, size: 20),
            label: const Text(
              'Simpan Perubahan',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ),
    );
  }
}

// =====================================================
// Formatter ribuan: 22000 -> 22.000
// =====================================================
class _ThousandFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return const TextEditingValue(text: '');

    final buf = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
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
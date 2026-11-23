import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../partials/colors.dart';

/// Hasil yang dikembalikan saat user menekan "Simpan Perubahan" / "Hapus bahan".
class EditBahanResult {
  final String name;
  final String category;
  final String unit;
  final double minStock;
  final int expiryLimitDays; // selalu dalam hari
  final bool deleted;

  const EditBahanResult({
    required this.name,
    required this.category,
    required this.unit,
    required this.minStock,
    required this.expiryLimitDays,
    this.deleted = false,
  });
}

/// Warna tambahan khusus halaman ini
class _C {
  static const helper = AppColors.warmLabel;
  static const lockedBg = AppColors.lockedFieldBg;
  static const hint = AppColors.mutedHint;
  static const iconBox = AppColors.iconBox;
  static const uploadBorder = AppColors.uploadBorder;
}

class EditInformasiBahanPage extends StatefulWidget {
  final String name;
  final String category;
  final String unit;
  final double minStock;
  final int expiryLimitDays;
  final String? imageAsset;

  /// Jumlah resep yang memakai bahan ini (ditampilkan di dialog hapus).
  /// TODO: isi dari API (bagian BE).
  final int recipeCount;

  /// Daftar pilihan (ganti dengan data dari backend jika perlu)
  final List<String> categories;
  final List<String> units;

  const EditInformasiBahanPage({
    super.key,
    required this.name,
    required this.category,
    this.unit = 'kg',
    this.minStock = 10,
    this.expiryLimitDays = 180,
    this.imageAsset,
    this.recipeCount = 3,
    this.categories = const [
      'Bahan Kering',
      'Minuman',
      'Susu dan Olahan',
      'Protein',
      'Bumbu & Rempah',
    ],
    this.units = const ['kg', 'g', 'liter', 'ml', 'pcs', 'pak'],
  });

  @override
  State<EditInformasiBahanPage> createState() => _EditInformasiBahanPageState();
}

class _EditInformasiBahanPageState extends State<EditInformasiBahanPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameCtrl;
  late final TextEditingController _newCategoryCtrl;
  late final TextEditingController _minCtrl;
  late final TextEditingController _expiryCtrl;

  late List<String> _categories;
  late List<String> _units;

  bool _useExisting = true; // true = kategori yang sudah ada
  late String _category;
  late String _unit;
  String _expiryUnit = 'hari';

  static const _expiryUnits = {
    'hari': 1,
    'minggu': 7,
    'bulan': 30,
    'tahun': 365,
  };

  @override
  void initState() {
    super.initState();
    _categories = List<String>.from(widget.categories);
    if (!_categories.contains(widget.category)) {
      _categories.insert(0, widget.category);
    }
    _units = List<String>.from(widget.units);
    if (!_units.contains(widget.unit)) _units.insert(0, widget.unit);

    _category = widget.category;
    _unit = widget.unit;

    _nameCtrl = TextEditingController(text: widget.name);
    _newCategoryCtrl = TextEditingController();
    _minCtrl = TextEditingController(text: _fmtNum(widget.minStock));
    _expiryCtrl = TextEditingController(text: '${widget.expiryLimitDays}');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _newCategoryCtrl.dispose();
    _minCtrl.dispose();
    _expiryCtrl.dispose();
    super.dispose();
  }

  static String _fmtNum(double v) {
    final s = v == v.roundToDouble() ? v.toInt().toString() : v.toString();
    return s.replaceAll('.', ',');
  }

  // ---------- aksi ----------
  void _pickImage() {
    // TODO: pakai package image_picker untuk ambil foto / galeri (maks. 5 MB)
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final minStock = double.parse(_minCtrl.text.trim().replaceAll(',', '.'));
    final expiryDays =
        int.parse(_expiryCtrl.text.trim()) * _expiryUnits[_expiryUnit]!;
    final category = _useExisting ? _category : _newCategoryCtrl.text.trim();

    Navigator.pop(
      context,
      EditBahanResult(
        name: _nameCtrl.text.trim(),
        category: category,
        unit: _unit,
        minStock: minStock,
        expiryLimitDays: expiryDays,
      ),
    );
  }

  Future<void> _delete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => _DeleteBahanDialog(
        name: _nameCtrl.text.trim(),
        recipeCount: widget.recipeCount,
      ),
    );

    if (ok == true && mounted) {
      Navigator.pop(
        context,
        EditBahanResult(
          name: _nameCtrl.text.trim(),
          category: _category,
          unit: _unit,
          minStock: 0,
          expiryLimitDays: 0,
          deleted: true,
        ),
      );
    }
  }

  // ---------- build ----------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(25, 20, 25, 32),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildUploadBox(),
                    const SizedBox(height: 20),

                    // Nama Bahan
                    _label('Nama Bahan'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _nameCtrl,
                      style: _inputStyle,
                      decoration: _dec(),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Nama bahan wajib diisi'
                          : null,
                    ),
                    const SizedBox(height: 20),

                    // Kategori
                    _label('Kategori Menu'),
                    const SizedBox(height: 8),
                    _buildCategoryRadio(),
                    const SizedBox(height: 8),
                    if (_useExisting)
                      _buildDropdown<String>(
                        value: _category,
                        items: _categories,
                        onChanged: (v) => setState(() => _category = v!),
                      )
                    else
                      TextFormField(
                        controller: _newCategoryCtrl,
                        style: _inputStyle,
                        decoration: _dec(hint: 'Nama kategori baru'),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Nama kategori wajib diisi'
                            : null,
                      ),
                    const SizedBox(height: 20),

                    // Satuan
                    _label('Satuan'),
                    const SizedBox(height: 8),
                    _buildDropdown<String>(
                      value: _unit,
                      items: _units,
                      onChanged: (v) => setState(() => _unit = v!),
                    ),
                    const SizedBox(height: 20),

                    // Batas Minimal
                    _label('Batas Minimal (Par Level)'),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _minCtrl,
                            style: _inputStyle,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'[0-9.,]'),
                              ),
                            ],
                            decoration: _dec(),
                            validator: (v) {
                              final n = double.tryParse(
                                (v ?? '').trim().replaceAll(',', '.'),
                              );
                              return n == null ? 'Isi angka yang valid' : null;
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 102,
                          height: 56,
                          decoration: BoxDecoration(
                            color: _C.lockedBg,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.brown),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _unit,
                                style: const TextStyle(
                                  fontFamily: kFont,
                                  fontSize: 14,
                                  color: AppColors.brown,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.lock_outline,
                                size: 15,
                                color: AppColors.brown,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _helper(
                      'Notifikasi stok menipis muncul saat stok di bawah angka ini.',
                    ),
                    const SizedBox(height: 20),

                    // Batas Kadaluwarsa
                    _label('Batas Kadaluwarsa'),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _expiryCtrl,
                            style: _inputStyle,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            decoration: _dec(),
                            validator: (v) {
                              final n = int.tryParse((v ?? '').trim());
                              return (n == null || n <= 0)
                                  ? 'Isi angka yang valid'
                                  : null;
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 102,
                          child: _buildDropdown<String>(
                            value: _expiryUnit,
                            items: _expiryUnits.keys.toList(),
                            onChanged: (v) => setState(() => _expiryUnit = v!),
                            normalWeight: true,
                            horizontalPadding: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _helper('Masa simpan standar sejak barang diterima.'),
                    const SizedBox(height: 20),

                    // Hapus bahan
                    InkWell(
                      onTap: _delete,
                      borderRadius: BorderRadius.circular(6),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 6,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.delete_outline,
                              size: 18,
                              color: AppColors.red,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Hapus bahan',
                              style: TextStyle(
                                fontFamily: kFont,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Simpan
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton.icon(
                        onPressed: _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.orange,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        icon: const Icon(Icons.check_circle_outline, size: 20),
                        label: const Text(
                          'Simpan Perubahan',
                          style: TextStyle(
                            fontFamily: kFont,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= HEADER =================
  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.headerBg,
        boxShadow: [
          BoxShadow(
            color: AppColors.overlayShadow,
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
                  padding: const EdgeInsets.only(left: 25),
                  onPressed: () => Navigator.maybePop(context),
                  icon: const Icon(
                    Icons.arrow_back,
                    color: AppColors.textDark,
                    size: 22,
                  ),
                ),
              ),
              const Text(
                'Edit Informasi Bahan',
                style: TextStyle(
                  fontFamily: kFont,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= UPLOAD FOTO =================
  Widget _buildUploadBox() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        height: 168,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: _C.uploadBorder, width: 1),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (widget.imageAsset != null)
              Image.asset(
                widget.imageAsset!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    Container(color: AppColors.cardBg),
              )
            else
              Container(color: AppColors.cardBg),
            // lapisan putih transparan di atas foto
            Container(color: Colors.white.withOpacity(0.78)),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                _CameraBox(),
                SizedBox(height: 12),
                Text(
                  'Ambil foto atau pilih dari galeri',
                  style: TextStyle(
                    fontFamily: kFont,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Maks. 5 MB',
                  style: TextStyle(
                    fontFamily: kFont,
                    fontSize: 12,
                    color: _C.helper,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ================= KOMPONEN KECIL =================
  static const _inputStyle = TextStyle(
    fontFamily: kFont,
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: AppColors.textDark,
  );

  Widget _label(String text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          text,
          style: const TextStyle(
            fontFamily: kFont,
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
        const Text(
          '*Wajib',
          style: TextStyle(
            fontFamily: kFont,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.red,
          ),
        ),
      ],
    );
  }

  Widget _helper(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: kFont,
        fontSize: 13,
        height: 1.35,
        color: _C.helper,
      ),
    );
  }

  OutlineInputBorder _border({Color color = AppColors.brown, double w = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: color, width: w),
    );
  }

  InputDecoration _dec({String? hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        fontFamily: kFont,
        fontSize: 14,
        color: _C.hint,
      ),
      errorStyle: const TextStyle(fontFamily: kFont, fontSize: 11),
      isDense: false,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      enabledBorder: _border(),
      focusedBorder: _border(w: 1.5),
      errorBorder: _border(color: AppColors.red),
      focusedErrorBorder: _border(color: AppColors.red, w: 1.5),
    );
  }

  Widget _buildDropdown<T>({
    required T value,
    required List<T> items,
    required ValueChanged<T?> onChanged,
    bool normalWeight = false,
    double horizontalPadding = 16,
  }) {
    return Container(
      height: 56,
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.brown),
        color: Colors.white,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(8),
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.brown,
          ),
          style: TextStyle(
            fontFamily: kFont,
            fontSize: 14,
            fontWeight: normalWeight ? FontWeight.w400 : FontWeight.w700,
            color: AppColors.textDark,
          ),
          items: items
              .map((e) => DropdownMenuItem<T>(value: e, child: Text('$e')))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildCategoryRadio() {
    Widget option(String label, bool selected, VoidCallback onTap) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              selected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              size: 20,
              color: AppColors.orange,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontFamily: kFont,
                fontSize: 13,
                color: AppColors.textDark,
              ),
            ),
          ],
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        option(
          'Kategori yang Sudah Ada',
          _useExisting,
          () => setState(() => _useExisting = true),
        ),
        option(
          'Kategori Baru',
          !_useExisting,
          () => setState(() => _useExisting = false),
        ),
      ],
    );
  }
}

class _CameraBox extends StatelessWidget {
  const _CameraBox();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: _C.iconBox,
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Icon(
        Icons.photo_camera_outlined,
        size: 24,
        color: AppColors.brown,
      ),
    );
  }
}

// =====================================================
// DIALOG KONFIRMASI HAPUS BAHAN
// =====================================================
class _DeleteBahanDialog extends StatelessWidget {
  final String name;
  final int recipeCount;

  const _DeleteBahanDialog({required this.name, required this.recipeCount});

  static const _body = TextStyle(
    fontFamily: kFont,
    fontSize: 14,
    height: 1.4,
    color: AppColors.textDark,
  );
  static const _accent = TextStyle(
    fontFamily: kFont,
    fontSize: 14,
    height: 1.4,
    color: AppColors.accent,
  );

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SizedBox(
        width: 272,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 20, 22, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Ikon tempat sampah
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  color: AppColors.deleteIconBg,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.delete_outline,
                  size: 32,
                  color: AppColors.red,
                ),
              ),
              const SizedBox(height: 24),

              // Judul
              const Text(
                'Hapus bahan?',
                style: TextStyle(
                  fontFamily: kFont,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 14),

              // Nama bahan + jumlah resep
              if (recipeCount > 0)
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(text: name, style: _accent),
                      const TextSpan(text: ' dipakai di ', style: _body),
                      TextSpan(text: '$recipeCount resep', style: _accent),
                      const TextSpan(text: '.', style: _body),
                    ],
                  ),
                  textAlign: TextAlign.center,
                )
              else
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(text: name, style: _accent),
                      const TextSpan(
                        text: ' belum dipakai di resep mana pun.',
                        style: _body,
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              const SizedBox(height: 18),

              // Penjelasan
              Text(
                recipeCount > 0
                    ? 'Jika dihapus, bahan ini hilang dari resep tersebut. Riwayat stoknya tetap tersimpan.'
                    : 'Riwayat stoknya tetap tersimpan.',
                textAlign: TextAlign.center,
                style: _body,
              ),
              const SizedBox(height: 26),

              // Tombol
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 40,
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context, false),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.brownDark,
                          side: const BorderSide(
                            color: AppColors.brownDark,
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Batal',
                          style: TextStyle(
                            fontFamily: kFont,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SizedBox(
                      height: 40,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.red,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Hapus',
                          style: TextStyle(
                            fontFamily: kFont,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

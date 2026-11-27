import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../../constants/ingredient_options.dart';
import '../../models/ingredient.dart';
import '../../services/cloudinary_service.dart';
import '../../services/ingredient_service.dart';
import '../partials/colors.dart';

/// Hasil yang dikembalikan saat halaman edit ditutup.
/// Penyimpanan dilakukan di halaman ini sendiri; pemanggil hanya perlu tahu
/// apakah bahannya dihapus (lalu menutup halaman detail).
class EditBahanResult {
  final bool deleted;

  const EditBahanResult({this.deleted = false});
}

enum _FotoAksi { kamera, galeri, hapus }

/// Warna tambahan khusus halaman ini
class _C {
  static const helper = AppColors.warmLabel;
  static const lockedBg = AppColors.lockedFieldBg;
  static const hint = AppColors.mutedHint;
  static const iconBox = AppColors.iconBox;
  static const uploadBorder = AppColors.uploadBorder;
}

class EditInformasiBahanPage extends StatefulWidget {
  final Ingredient ingredient;

  const EditInformasiBahanPage({super.key, required this.ingredient});

  @override
  State<EditInformasiBahanPage> createState() => _EditInformasiBahanPageState();
}

class _EditInformasiBahanPageState extends State<EditInformasiBahanPage> {
  static const int _maxFotoBytes = 5 * 1024 * 1024; // 5 MB

  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  late final TextEditingController _nameCtrl;
  late final TextEditingController _minCtrl;
  late final TextEditingController _expiryCtrl;

  late String _category; // kunci kategori
  late String _expiryUnit; // hari | minggu | bulan

  File? _newFoto; // foto baru yang dipilih (belum diunggah)
  bool _removePhoto = false; // true = foto lama dihapus
  bool _saving = false;

  Ingredient get _ing => widget.ingredient;

  /// Ada foto yang sedang ditampilkan (baru atau lama)?
  bool get _hasPhoto =>
      _newFoto != null ||
          (!_removePhoto && (_ing.photoUrl?.isNotEmpty ?? false));

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: _ing.name);
    _minCtrl = TextEditingController(
      text: _fmtNum(_ing.minStock / _ing.unit.factor),
    );
    _expiryCtrl = TextEditingController(text: '${_ing.shelfLifeValue}');

    // Kategori lama yang sudah tidak ada di daftar -> "Lainnya"
    _category = kCategories.any((c) => c.key == _ing.categoryKey)
        ? _ing.categoryKey
        : 'lainnya';
    _expiryUnit = kDurations.any((d) => d.key == _ing.shelfLifeUnit)
        ? _ing.shelfLifeUnit
        : 'hari';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _minCtrl.dispose();
    _expiryCtrl.dispose();
    super.dispose();
  }

  static String _fmtNum(double v) {
    final s = v == v.roundToDouble() ? v.toInt().toString() : v.toString();
    return s.replaceAll('.', ',');
  }

  void _pesan(String teks) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(teks)));
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
            if (_hasPhoto)
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
        setState(() {
          _newFoto = null;
          _removePhoto = true;
        });
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
      setState(() {
        _newFoto = file;
        _removePhoto = false;
      });
    } catch (e) {
      debugPrint('pickImage error: $e');
      _pesan('Tidak dapat mengakses kamera atau galeri');
    }
  }

  // ---------- Simpan ----------
  Future<void> _save() async {
    if (_saving) return;
    if (!_formKey.currentState!.validate()) return;

    final minStock = double.parse(_minCtrl.text.trim().replaceAll(',', '.'));
    final shelfValue = int.parse(_expiryCtrl.text.trim());
    final messenger = ScaffoldMessenger.of(context);

    setState(() => _saving = true);
    try {
      // 1) foto baru -> link Cloudinary
      String? newUrl;
      if (_newFoto != null) {
        newUrl = await CloudinaryService.instance.uploadImage(_newFoto!);
      }

      // 2) simpan perubahan
      await IngredientService.instance.updateIngredient(
        _ing.id,
        name: _nameCtrl.text,
        categoryKey: _category,
        unitKey: _ing.unitKey,
        minStock: minStock,
        shelfLifeValue: shelfValue,
        shelfLifeUnit: _expiryUnit,
        photoUrl: newUrl,
        removePhoto: _removePhoto && _newFoto == null,
      );
      if (!mounted) return;

      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('Perubahan disimpan')));
      Navigator.pop(context, const EditBahanResult());
    } on ServiceException catch (e) {
      _pesan(e.message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  // ---------- Hapus ----------
  Future<void> _delete() async {
    if (_saving) return;
    final messenger = ScaffoldMessenger.of(context);

    setState(() => _saving = true);
    try {
      final count = await IngredientService.instance.countRecipesUsing(_ing.id);
      if (!mounted) return;

      final ok = await showDialog<bool>(
        context: context,
        builder: (_) =>
            _DeleteBahanDialog(name: _ing.name, recipeCount: count),
      );
      if (ok != true) return;

      await IngredientService.instance.deleteIngredient(_ing.id);
      if (!mounted) return;

      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('Bahan dihapus')));
      Navigator.pop(context, const EditBahanResult(deleted: true));
    } on ServiceException catch (e) {
      _pesan(e.message);
    } finally {
      if (mounted) setState(() => _saving = false);
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
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
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
                      textCapitalization: TextCapitalization.words,
                      decoration: _dec(),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Nama bahan wajib diisi'
                          : null,
                    ),
                    const SizedBox(height: 20),

                    // Kategori
                    _label('Kategori Bahan'),
                    const SizedBox(height: 8),
                    _buildDropdown<String>(
                      value: _category,
                      items: kCategories.map((c) => c.key).toList(),
                      labelOf: (k) => categoryByKey(k).label,
                      onChanged: (v) => setState(() => _category = v!),
                    ),
                    const SizedBox(height: 20),

                    // Satuan (terkunci)
                    _label('Satuan'),
                    const SizedBox(height: 8),
                    _buildLockedBox(_ing.unit.label, fullWidth: true),
                    const SizedBox(height: 8),
                    _helper('Satuan tidak bisa diubah karena stok sudah tercatat.'),
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
                              return (n == null || n <= 0)
                                  ? 'Isi angka lebih dari 0'
                                  : null;
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        _buildLockedBox(_ing.unit.label),
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
                                  ? 'Isi angka lebih dari 0'
                                  : null;
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 102,
                          child: _buildDropdown<String>(
                            value: _expiryUnit,
                            items: kDurations.map((d) => d.key).toList(),
                            labelOf: (k) => k,
                            onChanged: (v) => setState(() => _expiryUnit = v!),
                            normalWeight: true,
                            horizontalPadding: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _helper(
                      'Masa simpan standar sejak barang diterima. '
                          'Berlaku untuk stok yang masuk berikutnya.',
                    ),
                    const SizedBox(height: 20),

                    // Hapus bahan
                    InkWell(
                      onTap: _saving ? null : _delete,
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
                      child: ElevatedButton(
                        onPressed: _saving ? null : _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.orange,
                          disabledBackgroundColor:
                          AppColors.orange.withOpacity(0.6),
                          foregroundColor: Colors.white,
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
                            : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_circle_outline, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Simpan Perubahan',
                              style: TextStyle(
                                fontFamily: kFont,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
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
                  onPressed: _saving ? null : () => Navigator.maybePop(context),
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

  // ================= FOTO =================
  Widget _buildUploadBox() {
    Widget photo = Container(color: AppColors.cardBg);
    if (_newFoto != null) {
      photo = Image.file(_newFoto!, fit: BoxFit.cover);
    } else if (!_removePhoto && (_ing.photoUrl?.isNotEmpty ?? false)) {
      photo = Image.network(
        cloudinaryResize(_ing.photoUrl!, width: 900),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(color: AppColors.cardBg),
      );
    }

    return GestureDetector(
      onTap: _saving ? null : _pilihFoto,
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
            photo,
            // lapisan putih transparan di atas foto
            Container(color: Colors.white.withOpacity(0.78)),
            const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      enabledBorder: _border(),
      focusedBorder: _border(w: 1.5),
      errorBorder: _border(color: AppColors.red),
      focusedErrorBorder: _border(color: AppColors.red, w: 1.5),
    );
  }

  /// Kotak satuan terkunci (mis. "kg 🔒").
  Widget _buildLockedBox(String text, {bool fullWidth = false}) {
    return Container(
      width: fullWidth ? double.infinity : 102,
      height: 56,
      decoration: BoxDecoration(
        color: _C.lockedBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.brown),
      ),
      padding: fullWidth ? const EdgeInsets.symmetric(horizontal: 16) : null,
      child: Row(
        mainAxisAlignment:
        fullWidth ? MainAxisAlignment.spaceBetween : MainAxisAlignment.center,
        children: [
          Text(
            text,
            style: const TextStyle(
              fontFamily: kFont,
              fontSize: 14,
              color: AppColors.brown,
            ),
          ),
          if (!fullWidth) const SizedBox(width: 4),
          const Icon(Icons.lock_outline, size: 15, color: AppColors.brown),
        ],
      ),
    );
  }

  Widget _buildDropdown<T>({
    required T value,
    required List<T> items,
    required String Function(T) labelOf,
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
              .map(
                (e) => DropdownMenuItem<T>(value: e, child: Text(labelOf(e))),
          )
              .toList(),
          onChanged: onChanged,
        ),
      ),
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
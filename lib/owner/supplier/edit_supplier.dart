import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../partials/colors.dart';
import 'edit_rincianbahan.dart' show EditInformasiMenuPage;

/// Hasil halaman Edit Supplier (dikirim balik lewat Navigator.pop).
/// Kalau [dihapus] true, halaman pemanggil sebaiknya menghapus supplier-nya.
class EditSupplierResult {
  final String nama;
  final String pic;
  final String telp;
  final String email;
  final String alamat;
  final bool dihapus;

  const EditSupplierResult({
    required this.nama,
    required this.pic,
    required this.telp,
    required this.email,
    required this.alamat,
    this.dihapus = false,
  });
}

/// Halaman Edit Informasi Supplier.
///
/// Contoh membuka dari halaman lain:
/// ```dart
/// final hasil = await Navigator.push<EditSupplierResult>(
///   context,
///   MaterialPageRoute(
///     builder: (_) => EditSupplierPage(
///       nama: s.nama,
///       pic: s.pic,
///       telp: s.telp,
///       email: s.email,
///       alamat: s.alamat,
///       onAturBahan: () { /* TODO: buka halaman rincian bahan */ },
///     ),
///   ),
/// );
/// ```
class EditSupplierPage extends StatefulWidget {
  final String nama;
  final String pic;
  final String telp; // boleh "0812-...", "+62 812-..." atau "812..."
  final String email;
  final String alamat;

  /// Dipanggil saat "Atur Rincian Bahan yang Disuplai" ditekan.
  final VoidCallback? onAturBahan;

  const EditSupplierPage({
    super.key,
    required this.nama,
    required this.pic,
    required this.telp,
    required this.email,
    required this.alamat,
    this.onAturBahan,
  });

  @override
  State<EditSupplierPage> createState() => _EditSupplierPageState();
}

class _EditSupplierPageState extends State<EditSupplierPage> {
  late final TextEditingController _nama;
  late final TextEditingController _pic;
  late final TextEditingController _telp;
  late final TextEditingController _email;
  late final TextEditingController _alamat;

  // Error baru ditampilkan setelah tombol "Simpan Perubahan" ditekan
  bool _tampilError = false;

  @override
  void initState() {
    super.initState();
    _nama = TextEditingController(text: widget.nama);
    _pic = TextEditingController(text: widget.pic);
    _telp = TextEditingController(text: _normalisasiTelp(widget.telp));
    _email = TextEditingController(text: widget.email);
    _alamat = TextEditingController(text: widget.alamat);
  }

  @override
  void dispose() {
    for (final c in [_nama, _pic, _telp, _email, _alamat]) {
      c.dispose();
    }
    super.dispose();
  }

  /// "+62 812-3344-5566" / "0812-3344-5566" -> "812-3344-5566"
  static String _normalisasiTelp(String raw) {
    var d = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (d.startsWith('62')) d = d.substring(2);
    d = d.replaceFirst(RegExp(r'^0+'), '');
    if (d.length > 12) d = d.substring(0, 12);
    final buf = StringBuffer();
    for (var i = 0; i < d.length; i++) {
      if (i == 3 || i == 7) buf.write('-');
      buf.write(d[i]);
    }
    return buf.toString();
  }

  // ===== Validasi =====
  bool get _emailValid =>
      RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(_email.text.trim());

  bool get _telpValid {
    final n = _telp.text.replaceAll(RegExp(r'[^0-9]'), '').length;
    return n >= 9 && n <= 12;
  }

  bool get _valid =>
      _nama.text.trim().isNotEmpty &&
      _pic.text.trim().isNotEmpty &&
      _telpValid &&
      _emailValid &&
      _alamat.text.trim().isNotEmpty;

  String? _errWajib(TextEditingController c, String pesan) =>
      (_tampilError && c.text.trim().isEmpty) ? pesan : null;

  String? get _errEmail {
    if (_email.text.trim().isEmpty) {
      return _tampilError ? 'Email wajib diisi' : null;
    }
    return _emailValid ? null : 'Format email tidak valid';
  }

  String? get _errTelp {
    final n = _telp.text.replaceAll(RegExp(r'[^0-9]'), '').length;
    if (n == 0) return _tampilError ? 'Nomor telepon wajib diisi' : null;
    if (!_telpValid) {
      return _tampilError ? 'Nomor terlalu pendek (minimal 9 digit)' : null;
    }
    return null;
  }

  // ===== Aksi =====
  EditSupplierResult _hasil({bool dihapus = false}) => EditSupplierResult(
        nama: _nama.text.trim(),
        pic: _pic.text.trim(),
        telp: '+62 ${_telp.text.trim()}',
        email: _email.text.trim(),
        alamat: _alamat.text.trim(),
        dihapus: dihapus,
      );

  void _simpan() {
    FocusScope.of(context).unfocus();
    if (!_valid) {
      setState(() => _tampilError = true);
      return;
    }
    // TODO: kirim perubahan ke API
    Navigator.pop(context, _hasil());
  }

  Future<void> _hapus() async {
    FocusScope.of(context).unfocus();

    // >>> PANGGIL POPUP HAPUS SUPPLIER (kodenya ada di paling bawah file ini)
    final yakin = await showDialog<bool>(
      context: context,
      builder: (_) => _HapusSupplierDialog(namaSupplier: _nama.text.trim().isEmpty
          ? widget.nama
          : _nama.text.trim()),
    );

    if (!mounted || yakin != true) return;
    // TODO: hapus supplier lewat API
    Navigator.pop(context, _hasil(dihapus: true));
  }

  // ===== Komponen =====
  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(text,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark)),
          const Text('*Wajib',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.red)),
        ],
      ),
    );
  }

  OutlineInputBorder _border({Color? color, double width = 1}) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: color ?? AppColors.brown, width: width),
      );

  Widget _field({
    required String label,
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboard,
    int minLines = 1,
    int maxLines = 1,
    String? errorText,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label(label),
          TextField(
            controller: controller,
            onChanged: (_) => setState(() {}),
            keyboardType: keyboard,
            minLines: minLines,
            maxLines: maxLines,
            textAlignVertical:
                maxLines > 1 ? TextAlignVertical.top : TextAlignVertical.center,
            style: const TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w400,
                  color: AppColors.mutedText),
              errorText: errorText,
              filled: true,
              fillColor: AppColors.background,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
              enabledBorder: _border(),
              focusedBorder: _border(width: 1.6),
              errorBorder: _border(color: AppColors.red),
              focusedErrorBorder: _border(color: AppColors.red, width: 1.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTelepon() {
    final err = _errTelp;
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label('Nomor Telepon/WhatsApp'),
          Container(
            height: 56,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: err != null ? AppColors.red : AppColors.brown),
            ),
            child: Row(
              children: [
                Container(
                  width: 58,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: AppColors.lockedFieldBg,
                    border: Border(right: BorderSide(color: AppColors.brown)),
                  ),
                  child: const Text('+62',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.brown)),
                ),
                Expanded(
                  child: TextField(
                    controller: _telp,
                    onChanged: (_) => setState(() {}),
                    keyboardType: TextInputType.phone,
                    inputFormatters: [_TelpFormatter()],
                    style: const TextStyle(
                        fontSize: 14.5, color: AppColors.textDark),
                    decoration: const InputDecoration(
                      hintText: '812-3456-7890',
                      hintStyle: TextStyle(
                          fontSize: 14.5, color: AppColors.mutedText),
                      border: InputBorder.none,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 14, vertical: 17),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (err != null)
            Padding(
              padding: const EdgeInsets.only(top: 6, left: 4),
              child: Text(err,
                  style: const TextStyle(fontSize: 12, color: AppColors.red)),
            ),
        ],
      ),
    );
  }

  Widget _buildHapus() {
    return Align(
      alignment: Alignment.centerLeft,
      child: InkWell(
        onTap: _hapus,
        borderRadius: BorderRadius.circular(6),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.delete_outline, size: 18, color: AppColors.red),
              SizedBox(width: 6),
              Text('Hapus supplier',
                  style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.red)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAturBahan() {
    return Material(
      color: AppColors.filterRowBg,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
      onTap: () {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const EditInformasiMenuPage()),
  );
},

        borderRadius: BorderRadius.circular(8),
        child: const SizedBox(
          width: double.infinity,
          height: 52,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 18),
            child: Row(
              children: [
                Expanded(
                  child: Text('Atur Rincian Bahan yang Disuplai',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: AppColors.brown)),
                ),
                Icon(Icons.chevron_right, size: 20, color: AppColors.brown),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Theme(
      data: theme.copyWith(
        textTheme: theme.textTheme.apply(fontFamily: kFont),
      ),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Column(
          children: [
            _Header(onBack: () => Navigator.pop(context)),
            Expanded(
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(25, 22, 25, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _field(
                      label: 'Nama Supplier',
                      controller: _nama,
                      hint: 'Contoh: CV Sumber Pangan Jaya',
                      errorText: _errWajib(_nama, 'Nama supplier wajib diisi'),
                    ),
                    _field(
                      label: 'Nama PIC (Person In Charge)',
                      controller: _pic,
                      hint: 'Nama kontak utama',
                      errorText: _errWajib(_pic, 'Nama PIC wajib diisi'),
                    ),
                    _buildTelepon(),
                    _field(
                      label: 'Email Perusahaan',
                      controller: _email,
                      hint: 'contoh@perusahaan.com',
                      keyboard: TextInputType.emailAddress,
                      errorText: _errEmail,
                    ),
                    _field(
                      label: 'Alamat Gudang / Kantor',
                      controller: _alamat,
                      hint:
                          'Masukkan alamat lengkap kantor atau gudang supplier...',
                      keyboard: TextInputType.multiline,
                      minLines: 4,
                      maxLines: 4,
                      errorText: _errWajib(_alamat, 'Alamat wajib diisi'),
                    ),
                  ],
                ),
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(25, 8, 25, 18),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHapus(),
                    const SizedBox(height: 10),
                    _buildAturBahan(),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: _simpan,
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: _valid
                              ? AppColors.orangeAccent
                              : AppColors.buttonBg,
                          foregroundColor:
                              _valid ? AppColors.white : AppColors.buttonText,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        icon: const Icon(Icons.check_circle_outline, size: 20),
                        label: const Text('Simpan Perubahan',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Format nomor setelah +62, mis. 81233445566 -> 812-3344-5566.
/// Angka 0 di depan dibuang karena sudah diwakili +62.
class _TelpFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    var d = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    d = d.replaceFirst(RegExp(r'^0+'), '');
    if (d.length > 12) d = d.substring(0, 12);

    final buf = StringBuffer();
    for (var i = 0; i < d.length; i++) {
      if (i == 3 || i == 7) buf.write('-');
      buf.write(d[i]);
    }
    final text = buf.toString();
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

// ===== Header =====
class _Header extends StatelessWidget {
  final VoidCallback onBack;
  const _Header({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.headerBg,
        boxShadow: [
          BoxShadow(
              color: AppColors.overlayShadow,
              blurRadius: 6,
              offset: Offset(0, 2)),
        ],
      ),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 14,
        bottom: 14,
        left: 20,
        right: 20,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack,
            behavior: HitTestBehavior.opaque,
            child: const Icon(Icons.arrow_back,
                size: 24, color: AppColors.textDark),
          ),
          const Expanded(
            child: Text('Edit Informasi Supplier',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark)),
          ),
          const SizedBox(width: 24),
        ],
      ),
    );
  }
}

// =====================================================================
// ====================  POPUP HAPUS SUPPLIER : MULAI  =================
// Dipanggil dari fungsi _hapus() di atas.
// Mengembalikan true (Hapus) / false (Batal) lewat Navigator.pop.
// Ubah teks judul / keterangan di bagian yang diberi tanda  <<< TEKS
// =====================================================================
class _HapusSupplierDialog extends StatelessWidget {
  final String namaSupplier;
  const _HapusSupplierDialog({required this.namaSupplier});

  static const _textDark = Color(0xFF1E1408);
  static const _brownDark = Color(0xFF4A2C0F);
  static const _gold = Color(0xFFC58A17);
  static const _red = Color(0xFFC62828);
  static const _redSoft = Color(0xFFFDE2DF);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Theme(
      data: theme.copyWith(
        textTheme: theme.textTheme.apply(fontFamily: kFont),
      ),
      child: Dialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 40),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ----- ikon tempat sampah -----
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  color: _redSoft,
                  borderRadius: BorderRadius.circular(16),
                ),
                child:
                    const Icon(Icons.delete_outline, size: 32, color: _red),
              ),
              const SizedBox(height: 20),

              // ----- judul -----
              Text.rich(
                TextSpan(
                  style: const TextStyle(
                    fontFamily: kFont,
                    fontSize: 16.5,
                    fontWeight: FontWeight.w700,
                    height: 1.35,
                    color: _textDark,
                  ),
                  children: [
                    const TextSpan(text: 'Hapus supplier ini?\n'), // <<< TEKS
                    TextSpan(
                      text: namaSupplier,
                      style: const TextStyle(color: _gold),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // ----- keterangan -----
              const Text(
                'Supplier akan dihapus dari\ndaftar supplier', // <<< TEKS
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, height: 1.4, color: _textDark),
              ),
              const SizedBox(height: 24),

              // ----- tombol Batal & Hapus -----
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context, false),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.white,
                          side: const BorderSide(color: _brownDark, width: 1),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('Batal',
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: _brownDark)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: _red,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('Hapus',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w700)),
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
// =====================================================================
// ====================  POPUP HAPUS SUPPLIER : SELESAI  ===============
// =====================================================================
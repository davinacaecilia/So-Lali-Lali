import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../partials/colors.dart';
import 'tambah_supplier(2).dart';

/// Langkah 1 dari 2: Identitas Perusahaan.
class TambahSupplierPage extends StatefulWidget {
  const TambahSupplierPage({super.key});

  @override
  State<TambahSupplierPage> createState() => _TambahSupplierPageState();
}

class _TambahSupplierPageState extends State<TambahSupplierPage> {
  final _nama = TextEditingController();
  final _pic = TextEditingController();
  final _telp = TextEditingController();
  final _email = TextEditingController();
  final _alamat = TextEditingController();

  @override
  void dispose() {
    for (final c in [_nama, _pic, _telp, _email, _alamat]) {
      c.dispose();
    }
    super.dispose();
  }

  // ===== Validasi =====
  bool get _emailTerisi => _email.text.trim().isNotEmpty;

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

  // Error baru ditampilkan setelah tombol "Berikutnya" ditekan
  bool _tampilError = false;

  String? _errWajib(TextEditingController c, String pesan) =>
      (_tampilError && c.text.trim().isEmpty) ? pesan : null;

  String? get _errEmail {
    if (!_emailTerisi) return _tampilError ? 'Email wajib diisi' : null;
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

  /// Buka langkah 2. Kalau langkah 2 selesai (mengembalikan hasil),
  /// teruskan hasilnya ke halaman daftar.
  Future<void> _berikutnya() async {
    FocusScope.of(context).unfocus();
    if (!_valid) {
      setState(() => _tampilError = true); // tampilkan field yang belum benar
      return;
    }

    final hasil = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => TambahSupplier2Page(
          nama: _nama.text.trim(),
          pic: _pic.text.trim(),
          telp: '+62 ${_telp.text.trim()}',
          email: _email.text.trim(),
          alamat: _alamat.text.trim(),
        ),
      ),
    );

    if (!mounted || hasil == null) return;
    Navigator.pop(context, hasil);
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
            style: const TextStyle(fontSize: 14.5, color: AppColors.textDark),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle:
                  const TextStyle(fontSize: 14.5, color: AppColors.mutedText),
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

  Widget _buildProgress() {
    Widget bar(bool aktif) => Container(
          height: 5,
          decoration: BoxDecoration(
            color: aktif ? AppColors.orangeAccent : AppColors.buttonBg,
            borderRadius: BorderRadius.circular(3),
          ),
        );

    return Padding(
      padding: const EdgeInsets.fromLTRB(25, 16, 25, 0),
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Langkah 1 dari 2',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.accent)),
              Text('IDENTITAS PERUSAHAAN',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.4,
                      color: AppColors.mutedBrown)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: bar(true)),
              const SizedBox(width: 8),
              Expanded(child: bar(false)),
            ],
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
                  style:
                      const TextStyle(fontSize: 12, color: AppColors.red)),
            ),
        ],
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
            _buildProgress(),
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
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _berikutnya,
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor:
                          _valid ? AppColors.orangeAccent : AppColors.buttonBg,
                      foregroundColor:
                          _valid ? AppColors.white : AppColors.buttonText,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Berikutnya',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w700)),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward, size: 18),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Format nomor setelah +62, mis. 81234567890 -> 812-3456-7890.
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
            child: Text('Tambah Supplier Baru',
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
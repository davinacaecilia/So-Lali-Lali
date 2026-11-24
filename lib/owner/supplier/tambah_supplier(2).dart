import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../partials/colors.dart';
import 'popup_pilihbahan.dart';

/// true  = daftar bahan terisi 4 bahan contoh (untuk melihat tampilan)
/// false = daftar mulai kosong (pakai ini kalau sudah dipakai sungguhan)
const bool kIsiBahanContoh = true;

/// Bahan yang diinput di langkah 2.
class BahanBaru {
  final String nama;
  final int harga;
  final String satuan;
  final bool utama; // dijadikan supplier utama untuk bahan ini
  const BahanBaru({
    required this.nama,
    required this.harga,
    this.satuan = 'kg',
    this.utama = false,
  });
}

/// Hasil akhir form Tambah Supplier (dikirim balik lewat Navigator.pop).
class TambahSupplierResult {
  final String nama;
  final String pic;
  final String telp;
  final String email;
  final String alamat;
  final String termin;
  final List<BahanBaru> bahan;
  final List<String> kategori;
  final bool aktif;

  const TambahSupplierResult({
    required this.nama,
    required this.pic,
    required this.telp,
    required this.email,
    required this.alamat,
    required this.termin,
    required this.bahan,
    this.kategori = const [],
    this.aktif = true,
  });
}

const _bahanContoh = [
  BahanBaru(nama: 'Biji Kopi Arabika', harga: 22000),
  BahanBaru(nama: 'Biji Kopi Arabika', harga: 22000),
  BahanBaru(nama: 'Biji Kopi Arabika', harga: 22000),
  BahanBaru(nama: 'Biji Kopi Arabika', harga: 22000),
];

String _rupiah(int n) {
  final s = n.toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
    buf.write(s[i]);
  }
  return 'Rp $buf';
}

/// Toast sukses (kotak cokelat gelap, ikon centang hijau, aksi "Lihat").
/// Bisa dipakai ulang di halaman lain.
void tampilToastSukses(
  ScaffoldMessengerState messenger,
  String pesan, {
  VoidCallback? onLihat,
  String labelAksi = 'Lihat',
}) {
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        // fixed = menempel tepat di atas bottom nav (seperti snackbar lama),
        // FAB otomatis ikut naik. floating akan muncul di atas FAB.
        behavior: SnackBarBehavior.fixed,
        backgroundColor: Colors.transparent,
        elevation: 0,
        clipBehavior: Clip.none,
        padding: const EdgeInsets.symmetric(horizontal: 25),
        duration: const Duration(seconds: 4),
        content: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          decoration: BoxDecoration(
            color: const Color(0xFF3B2A1A),
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.check, size: 20, color: Color(0xFF5FD38D)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  pesan,
                  style: const TextStyle(
                    fontFamily: kFont,
                    fontSize: 14.5,
                    color: Colors.white,
                  ),
                ),
              ),
              if (onLihat != null) ...[
                const SizedBox(width: 12),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    messenger.hideCurrentSnackBar();
                    onLihat();
                  },
                  child: Text(
                    labelAksi,
                    style: const TextStyle(
                      fontFamily: kFont,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFF2C94C),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
}

class TambahSupplier2Page extends StatefulWidget {
  // Data dari langkah 1
  final String nama;
  final String pic;
  final String telp;
  final String email;
  final String alamat;

  const TambahSupplier2Page({
    super.key,
    required this.nama,
    required this.pic,
    required this.telp,
    required this.email,
    required this.alamat,
  });

  @override
  State<TambahSupplier2Page> createState() => _TambahSupplier2PageState();
}

class _TambahSupplier2PageState extends State<TambahSupplier2Page> {
  static const _opsiTermin = [
    'Tunai (COD)',
    '7 hari',
    '14 hari',
    '30 hari',
    '45 hari',
    '60 hari',
  ];

  String? _termin = '14 hari';
  late final List<BahanBaru> _bahan;

  @override
  void initState() {
    super.initState();
    _bahan = kIsiBahanContoh ? List.of(_bahanContoh) : [];
  }

  bool get _valid => _termin != null && _bahan.isNotEmpty;

  void _simpan() {
    if (!_valid) return;

    // Ambil messenger sebelum halaman ditutup, lalu tampilkan toast
    // (toast tetap muncul di halaman tujuan setelah pop).
    final messenger = ScaffoldMessenger.of(context);

    Navigator.pop(
      context,
      TambahSupplierResult(
        nama: widget.nama,
        pic: widget.pic,
        telp: widget.telp,
        email: widget.email,
        alamat: widget.alamat,
        termin: _termin!,
        bahan: List.of(_bahan),
      ),
    );

    tampilToastSukses(
      messenger,
      'Supplier berhasil ditambahkan',
      onLihat: () {
        // TODO: arahkan ke detail supplier yang baru ditambahkan
      },
    );
  }

  /// Klik "Tambah Bahan" -> buka popup Pilih Bahan (mode supplier).
  Future<void> _tambahBahan() async {
    final picked = await showPilihBahanSheet(
      context,
      options: daftarBahanContoh, // TODO: ganti dengan data dari API
      usedNames: _bahan.map((b) => b.nama.toLowerCase()).toSet(),
      onTambahBaru: _tambahBahanManual,
      mode: PilihBahanMode.supplier,
      usedLabel: 'Sudah ditambahkan',
    );
    if (!mounted || picked == null) return;

    setState(() {
      _bahan.add(BahanBaru(
        nama: picked.option.name,
        harga: picked.price, // harga dari supplier ini
        satuan: picked.option.unit,
        utama: picked.isMain,
      ));
    });
  }

  /// Klik "Bahan tidak ada? Tambah bahan baru" di popup -> form manual.
  Future<void> _tambahBahanManual() async {
    final baru = await showModalBottomSheet<BahanBaru>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _TambahBahanSheet(),
    );
    if (!mounted || baru == null) return;
    setState(() => _bahan.add(baru));
  }

  // ===== Komponen =====
  Widget _label(String text, {String? subtitle}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(text,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark)),
              if (subtitle != null)
                Text(subtitle,
                    style: const TextStyle(
                        fontSize: 13, color: AppColors.warmSubtitle)),
            ],
          ),
          const Text('*Wajib',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.red)),
        ],
      ),
    );
  }

  OutlineInputBorder _border({double width = 1}) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: AppColors.brown, width: width),
      );

  // ===== Indikator langkah =====
  Widget _buildProgress() {
    Widget bar() => Container(
          height: 5,
          decoration: BoxDecoration(
            color: AppColors.orangeAccent,
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
              Text('Langkah 2 dari 2',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.accent)),
              Text('INFORMASI LANJUTAN',
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
              Expanded(child: bar()),
              const SizedBox(width: 8),
              Expanded(child: bar()),
            ],
          ),
        ],
      ),
    );
  }

  // ===== Termin =====
  Widget _buildTermin() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('Termin Pembayaran',
            subtitle: 'Kesepakatan waktu pelunasan transaksi'),
        const SizedBox(height: 2),
        DropdownButtonFormField<String>(
          value: _termin,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down,
              color: AppColors.brown, size: 24),
          dropdownColor: AppColors.background,
          borderRadius: BorderRadius.circular(10),
          style: const TextStyle(fontSize: 14.5, color: AppColors.brown),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.background,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            enabledBorder: _border(),
            focusedBorder: _border(width: 1.6),
          ),
          items: _opsiTermin
              .map((t) => DropdownMenuItem(value: t, child: Text(t)))
              .toList(),
          onChanged: (v) => setState(() => _termin = v),
        ),
      ],
    );
  }

  // ===== Daftar bahan =====
  Widget _buildBahan() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('Bahan yang Disuplai'),
        if (_bahan.isEmpty)
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Text('Belum ada bahan. Tambahkan minimal satu bahan.',
                style: TextStyle(fontSize: 12.5, color: AppColors.photoHint)),
          ),
        ..._bahan.asMap().entries.map((e) => _barisBahan(e.key, e.value)),
        const SizedBox(height: 2),
        _tombolTambahBahan(),
      ],
    );
  }

  Widget _barisBahan(int index, BahanBaru b) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: SizedBox(
        height: 56,
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.brown, width: 1),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(7),
                  child: Row(
                    children: [
                      // nama bahan
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: Text(
                            b.nama,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 15,
                              color: AppColors.textDark,
                            ),
                          ),
                        ),
                      ),
                      // harga + satuan (kotak krem di kanan)
                      Container(
                        height: double.infinity,
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        decoration: const BoxDecoration(
                          color: Color(0xFFF3E8D6),
                          border: Border(
                            left: BorderSide(color: AppColors.brown, width: 1),
                          ),
                        ),
                        child: Text(
                          '${_rupiah(b.harga)}/${b.satuan}',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.brown,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 11),
            // tombol hapus baris
            InkWell(
              onTap: () => setState(() => _bahan.removeAt(index)),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 60,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.brown, width: 1),
                ),
                child: const Icon(Icons.remove,
                    size: 20, color: AppColors.textDark),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tombolTambahBahan() {
    return Material(
      color: AppColors.filterRowBg,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: _tambahBahan,
        borderRadius: BorderRadius.circular(8),
        child: const SizedBox(
          width: double.infinity,
          height: 56,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_circle_outline,
                  size: 20, color: AppColors.textDark),
              SizedBox(width: 8),
              Text('Tambah Bahan',
                  style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark)),
            ],
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
            _buildProgress(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(25, 22, 25, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTermin(),
                    const SizedBox(height: 22),
                    _buildBahan(),
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
                    onPressed: _valid ? _simpan : null,
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: AppColors.orangeAccent,
                      foregroundColor: AppColors.white,
                      disabledBackgroundColor: AppColors.buttonBg,
                      disabledForegroundColor: AppColors.buttonText,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Tambah Supplier',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700)),
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

// ===== Bottom sheet: Tambah Bahan (form manual) =====
class _TambahBahanSheet extends StatefulWidget {
  const _TambahBahanSheet();

  @override
  State<_TambahBahanSheet> createState() => _TambahBahanSheetState();
}

class _TambahBahanSheetState extends State<_TambahBahanSheet> {
  final _nama = TextEditingController();
  final _harga = TextEditingController();
  final _satuan = TextEditingController(text: 'kg');

  @override
  void dispose() {
    _nama.dispose();
    _harga.dispose();
    _satuan.dispose();
    super.dispose();
  }

  int get _hargaInt =>
      int.tryParse(_harga.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

  bool get _valid =>
      _nama.text.trim().isNotEmpty &&
      _satuan.text.trim().isNotEmpty &&
      _hargaInt > 0;

  void _simpan() {
    if (!_valid) return;
    Navigator.pop(
      context,
      BahanBaru(
        nama: _nama.text.trim(),
        harga: _hargaInt,
        satuan: _satuan.text.trim(),
      ),
    );
  }

  OutlineInputBorder _border({double width = 1}) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: AppColors.brown, width: width),
      );

  Widget _field(String label, TextEditingController c, String hint,
      {bool angka = false, List<TextInputFormatter>? formatters}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark)),
          const SizedBox(height: 8),
          TextField(
            controller: c,
            onChanged: (_) => setState(() {}),
            keyboardType: angka ? TextInputType.number : TextInputType.text,
            inputFormatters: formatters,
            style: const TextStyle(fontSize: 14.5, color: AppColors.textDark),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle:
                  const TextStyle(fontSize: 14.5, color: AppColors.mutedText),
              filled: true,
              fillColor: AppColors.background,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
              enabledBorder: _border(),
              focusedBorder: _border(width: 1.6),
            ),
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
      child: Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Container(
                      width: 48,
                      height: 5,
                      decoration: BoxDecoration(
                        color: AppColors.dragHandle,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      const Expanded(
                        child: Text('Tambah Bahan',
                            style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textDark)),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.peach,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.close,
                              size: 20, color: AppColors.brownDark),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  _field('Nama Bahan', _nama, 'Contoh: Biji Kopi Arabika'),
                  _field('Harga per Satuan (Rp)', _harga, '22.000',
                      angka: true, formatters: [_RibuanFormatter()]),
                  _field('Satuan', _satuan, 'kg, liter, pcs'),
                  const SizedBox(height: 4),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _valid ? _simpan : null,
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: AppColors.orangeAccent,
                        foregroundColor: AppColors.white,
                        disabledBackgroundColor: AppColors.buttonBg,
                        disabledForegroundColor: AppColors.buttonText,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Tambah Bahan',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RibuanFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    var d = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (d.length > 9) d = d.substring(0, 9);
    if (d.isEmpty) return const TextEditingValue(text: '');
    final buf = StringBuffer();
    for (var i = 0; i < d.length; i++) {
      if (i > 0 && (d.length - i) % 3 == 0) buf.write('.');
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
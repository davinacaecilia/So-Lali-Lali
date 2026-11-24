import 'package:flutter/material.dart';

import '../partials/colors.dart';
import 'popup_ubahharga.dart';
import 'edit_supplier.dart';

// ===== Model =====
enum StatusStok { aman, menipis, habis }

class BahanSupplier {
  final String nama;
  final String kategori;
  final int harga;
  final String satuan;
  final int stok;
  final int stokMinimum;
  final bool utama;

  const BahanSupplier({
    required this.nama,
    this.kategori = 'Lainnya',
    required this.harga,
    required this.satuan,
    required this.stok,
    required this.stokMinimum,
    this.utama = false,
  });

  StatusStok get status {
    if (stok <= 0) return StatusStok.habis;
    if (stok <= stokMinimum) return StatusStok.menipis;
    return StatusStok.aman;
  }

  BahanSupplier copyWith({int? harga, bool? utama}) => BahanSupplier(
        nama: nama,
        kategori: kategori,
        harga: harga ?? this.harga,
        satuan: satuan,
        stok: stok,
        stokMinimum: stokMinimum,
        utama: utama ?? this.utama,
      );
}

String _rupiah(int n) {
  final s = n.toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
    buf.write(s[i]);
  }
  return 'Rp $buf';
}

// ===== Data dummy (dipakai kalau parameter `bahan` tidak diisi) =====
const _dataDummy = [
  BahanSupplier(
      nama: 'Susu UHT Full Cream',
      kategori: 'Susu dan Olahan',
      harga: 18000,
      satuan: 'liter',
      stok: 6,
      stokMinimum: 10,
      utama: true),
  BahanSupplier(
      nama: 'Mentega',
      kategori: 'Susu dan Olahan',
      harga: 95000,
      satuan: 'kg',
      stok: 2,
      stokMinimum: 5,
      utama: true),
  BahanSupplier(
      nama: 'Keju Mozzarella',
      kategori: 'Susu dan Olahan',
      harga: 120000,
      satuan: 'kg',
      stok: 9,
      stokMinimum: 5),
  BahanSupplier(
      nama: 'Tepung Terigu',
      kategori: 'Bahan Kering',
      harga: 14000,
      satuan: 'kg',
      stok: 16,
      stokMinimum: 10),
  BahanSupplier(
      nama: 'Fillet Ayam',
      kategori: 'Daging',
      harga: 45000,
      satuan: 'kg',
      stok: 0,
      stokMinimum: 5),
];

class DetailSupplierPage extends StatefulWidget {
  final String nama;
  final String pic;
  final String telp;
  final String email;
  final String alamat;
  final String termin;
  final String supplierId;
  final bool aktif;

  /// Daftar bahan supplier.
  /// - tidak diisi (null)  -> pakai data dummy (tampilan gambar 2)
  /// - diisi `const []`    -> kosong (tampilan gambar 1)
  final List<BahanSupplier>? bahan;

  const DetailSupplierPage({
    super.key,
    required this.nama,
    required this.pic,
    required this.telp,
    this.email = 'order@sumberpanganjaya.co.id',
    this.alamat = 'Jl. Industri No. 21, Kawasan Industri',
    this.termin = '14 hari',
    this.supplierId = 'SPJ-041',
    this.aktif = true,
    this.bahan,
  });

  @override
  State<DetailSupplierPage> createState() => _DetailSupplierPageState();
}

class _DetailSupplierPageState extends State<DetailSupplierPage> {
  late final List<BahanSupplier> _bahan;

  // Data kontak disimpan di state supaya bisa berubah setelah diedit.
  late String _nama;
  late String _pic;
  late String _telp;
  late String _email;
  late String _alamat;

  @override
  void initState() {
    super.initState();
    _bahan = List.of(widget.bahan ?? _dataDummy);
    _nama = widget.nama;
    _pic = widget.pic;
    _telp = widget.telp;
    _email = widget.email;
    _alamat = widget.alamat;
  }

  String get _inisial => _nama
      .split(' ')
      .where((e) => e.isNotEmpty)
      .skip(1)
      .take(2)
      .map((e) => e[0].toUpperCase())
      .join();

  int get _perluDipesan =>
      _bahan.where((b) => b.status != StatusStok.aman).length;

  /// Ikon pulpen di "Informasi Kontak": buka halaman Edit Supplier.
  Future<void> _editKontak() async {
    final hasil = await Navigator.push<EditSupplierResult>(
      context,
      MaterialPageRoute(
        builder: (_) => EditSupplierPage(
          nama: _nama,
          pic: _pic,
          telp: _telp,
          email: _email,
          alamat: _alamat,
          // Daftar bahan ada di halaman ini, jadi cukup kembali.
          onAturBahan: () => Navigator.pop(context),
        ),
      ),
    );
    if (!mounted || hasil == null) return;

    if (hasil.dihapus) {
      // Supplier dihapus: tutup halaman detail dan teruskan hasilnya.
      Navigator.pop(context, hasil);
      return;
    }

    setState(() {
      _nama = hasil.nama;
      _pic = hasil.pic;
      _telp = hasil.telp;
      _email = hasil.email;
      _alamat = hasil.alamat;
    });
  }

  /// Tombol "+ Tambah" dan "Tambah Bahan".
  /// TODO: buka halaman tambah bahan, lalu setState(() => _bahan.add(hasil)).
  void _tambahBahan() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Halaman tambah bahan belum dibuat')),
    );
  }

  /// Ketuk salah satu bahan: buka popup Ubah Harga.
  Future<void> _ubahHarga(int index) async {
    final b = _bahan[index];
    final hasil = await UbahHargaSheet.show(
      context,
      namaBahan: b.nama,
      kategori: b.kategori,
      satuan: b.satuan,
      hargaAwal: b.harga,
      utama: b.utama,
      namaSupplier: _nama,
      idSupplier: widget.supplierId,
    );
    if (!mounted || hasil == null) return;
    setState(() {
      if (hasil.hapus) {
        _bahan.removeAt(index);
      } else {
        _bahan[index] = b.copyWith(harga: hasil.harga, utama: hasil.utama);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final punyaBahan = _bahan.isNotEmpty;

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
                padding: const EdgeInsets.fromLTRB(12, 18, 12, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProfil(),
                    const SizedBox(height: 16),
                    _buildTombolKontak(),
                    const SizedBox(height: 22),
                    _buildInfoKontak(),
                    const SizedBox(height: 22),
                    _buildBahan(punyaBahan),
                  ],
                ),
              ),
            ),
            _buildBottomPO(punyaBahan),
          ],
        ),
      ),
    );
  }

  // ===== Profil =====
  Widget _buildProfil() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 13),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.iconBox,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(_inisial,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.warningStatusText)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_nama,
                    style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark)),
                const SizedBox(height: 2),
                Text('PIC: $_pic · $_telp',
                    style: const TextStyle(
                        fontSize: 12.5, color: AppColors.neutralText)),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: widget.aktif
                        ? AppColors.safeTagBg
                        : AppColors.exhaustedStatusBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(widget.aktif ? Icons.check : Icons.close,
                          size: 11,
                          color: widget.aktif
                              ? AppColors.green
                              : AppColors.red),
                      const SizedBox(width: 3),
                      Text(widget.aktif ? 'Aktif' : 'Nonaktif',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: widget.aktif
                                  ? AppColors.green
                                  : AppColors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===== Tombol Telepon & WhatsApp =====
  Widget _buildTombolKontak() {
    Widget tombol(IconData icon, String label, VoidCallback onTap) {
      return Expanded(
        child: SizedBox(
          height: 48,
          child: ElevatedButton.icon(
            onPressed: onTap,
            icon: Icon(icon, size: 20, color: AppColors.white),
            label: Text(label,
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.barDark,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 13),
      child: Row(
        children: [
          tombol(Icons.call, 'Telepon', () {
            // TODO: buka dialer (url_launcher: tel:$_telp)
          }),
          const SizedBox(width: 12),
          tombol(Icons.chat, 'WhatsApp', () {
            // TODO: buka WhatsApp (url_launcher)
          }),
        ],
      ),
    );
  }

  // ===== Judul section dengan garis =====
  Widget _sectionTitle(String title, Widget trailing) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.sectionText)),
            trailing,
          ],
        ),
        const SizedBox(height: 8),
        Container(height: 2, color: AppColors.buttonBg),
      ],
    );
  }

  // ===== Informasi Kontak =====
  Widget _buildInfoKontak() {
    Widget baris(String label, String value) => Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 14, color: AppColors.neutralText)),
              const SizedBox(width: 24),
              Expanded(
                child: Text(value,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                        fontSize: 14, color: AppColors.textDark)),
              ),
            ],
          ),
        );

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 2),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
              color: AppColors.subtleShadow,
              blurRadius: 6,
              offset: Offset(0, 1)),
        ],
      ),
      child: Column(
        children: [
          _sectionTitle(
            'Informasi Kontak',
            GestureDetector(
              onTap: _editKontak,
              behavior: HitTestBehavior.opaque,
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(Icons.edit_outlined,
                    size: 22, color: AppColors.sectionText),
              ),
            ),
          ),
          const SizedBox(height: 14),
          baris('PIC', _pic),
          baris('Telepon', _telp),
          baris('Email', _email),
          baris('Alamat', _alamat),
          baris('Termin Pembayaran', widget.termin),
        ],
      ),
    );
  }

  // ===== Bahan yang Disuplai =====
  Widget _buildBahan(bool punyaBahan) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          _sectionTitle(
            'Bahan yang Disuplai (${_bahan.length})',
            GestureDetector(
              onTap: _tambahBahan,
              child: const Text('+ Tambah',
                  style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w500,
                      color: AppColors.sectionText)),
            ),
          ),
          const SizedBox(height: 14),
          if (punyaBahan) ...[
            if (_perluDipesan > 0) _buildBannerInfo(),
            ..._bahan.asMap().entries.map((e) => _BahanTile(
                  bahan: e.value,
                  isLast: e.key == _bahan.length - 1,
                  onTap: () => _ubahHarga(e.key),
                )),
          ] else
            _buildEmptyState(),
        ],
      ),
    );
  }

  Widget _buildBannerInfo() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.infoBg,
        border: Border.all(color: AppColors.infoBorder),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, size: 18, color: AppColors.infoText),
          const SizedBox(width: 8),
          Text('$_perluDipesan bahan perlu dipesan',
              style: const TextStyle(fontSize: 13, color: AppColors.infoText)),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 28, 22, 28),
      decoration: BoxDecoration(
        color: AppColors.cardHighlight,
        border: Border.all(color: AppColors.cardBorder),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.peach,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.inventory_2_outlined,
                size: 30, color: AppColors.brown),
          ),
          const SizedBox(height: 18),
          const Text('Belum ada bahan yang disuplai',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark)),
          const SizedBox(height: 8),
          const Text(
            'Tambahkan bahan baku yang dipasok oleh supplier ini untuk mulai mengelola stok dan PO.',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 12.5, height: 1.4, color: AppColors.photoHint),
          ),
          const SizedBox(height: 18),
          OutlinedButton.icon(
            onPressed: _tambahBahan,
            icon: const Icon(Icons.add, size: 18, color: AppColors.barDark),
            label: const Text('Tambah Bahan',
                style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.barDark)),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(142, 40),
              side: const BorderSide(color: AppColors.barDark),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }

  // ===== Tombol Buat Purchase Order =====
  Widget _buildBottomPO(bool punyaBahan) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(25, 6, 25, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!punyaBahan)
              const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Text('Tambahkan bahan dulu untuk membuat pesanan',
                    style: TextStyle(
                        fontSize: 12, color: AppColors.photoHint)),
              ),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: punyaBahan
                    ? () {
                        // TODO: buat purchase order
                      }
                    : null,
                icon: const Icon(Icons.add_shopping_cart, size: 20),
                label: const Text('Buat Purchase Order',
                    style:
                        TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: AppColors.orangeAccent,
                  foregroundColor: AppColors.white,
                  disabledBackgroundColor: AppColors.navDivider,
                  disabledForegroundColor: AppColors.mutedIcon,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ===== Item bahan =====
class _BahanTile extends StatelessWidget {
  final BahanSupplier bahan;
  final bool isLast;
  final VoidCallback onTap;
  const _BahanTile(
      {required this.bahan, required this.isLast, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          border: isLast
              ? null
              : const Border(
                  bottom: BorderSide(color: AppColors.rowDivider, width: 1.5)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(bahan.nama,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textDark)),
                      ),
                      if (bahan.utama) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: AppColors.chipBg,
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: const Text('Utama',
                              style: TextStyle(
                                  fontSize: 10,
                                  color: AppColors.warmSubtitle)),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text('${_rupiah(bahan.harga)} / ${bahan.satuan}',
                      style: const TextStyle(
                          fontSize: 12.5, color: AppColors.summarySubtitle)),
                ],
              ),
            ),
            _StatusPill(bahan: bahan),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right,
                size: 18, color: AppColors.textDark),
          ],
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final BahanSupplier bahan;
  const _StatusPill({required this.bahan});

  @override
  Widget build(BuildContext context) {
    late final Color bg;
    late final Color fg;
    late final IconData icon;
    late final String label;

    switch (bahan.status) {
      case StatusStok.menipis:
        bg = AppColors.warningStatusBg;
        fg = AppColors.warningStatusText;
        icon = Icons.warning_amber_rounded;
        label = 'Menipis';
        break;
      case StatusStok.habis:
        bg = AppColors.exhaustedStatusBg;
        fg = AppColors.red;
        icon = Icons.cancel_outlined;
        label = 'Habis';
        break;
      case StatusStok.aman:
        bg = AppColors.safeBg;
        fg = AppColors.safeText;
        icon = Icons.check_circle_outline;
        label = 'Aman';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: fg),
          const SizedBox(width: 4),
          Text('$label (${bahan.stok} ${bahan.satuan})',
              style: TextStyle(
                  fontSize: 11.5, fontWeight: FontWeight.w600, color: fg)),
        ],
      ),
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
            child: Text('Detail Supplier',
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
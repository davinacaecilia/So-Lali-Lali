import 'dart:async';

import 'package:flutter/material.dart';

import '../../constants/ingredient_options.dart' show formatQty;
import '../../constants/supplier_options.dart';
import '../../models/ingredient.dart';
import '../../models/supplier_data.dart';
import '../../services/ingredient_service.dart';
import '../../services/supplier_service.dart';
import '../partials/colors.dart';

// ===== Model tampilan =====
enum StatusStok { aman, menipis, habis }

class BahanSupplier {
  final String? ingredientId;
  final String nama;
  final String kategori;
  final int harga; // rupiah per satuan
  final String satuan;
  final double stok; // dalam satuan bahan (mis. kg)
  final double stokMinimum;
  final String? stokText; // mis. "6 L" (siap tampil)
  final bool utama;

  const BahanSupplier({
    this.ingredientId,
    required this.nama,
    this.kategori = 'Lainnya',
    required this.harga,
    required this.satuan,
    required this.stok,
    required this.stokMinimum,
    this.stokText,
    this.utama = false,
  });

  StatusStok get status {
    if (stok <= 0) return StatusStok.habis;
    if (stok < stokMinimum) return StatusStok.menipis;
    return StatusStok.aman;
  }

  String get stokLabel => stokText ?? '$stok $satuan';

  BahanSupplier copyWith({int? harga, bool? utama}) => BahanSupplier(
    ingredientId: ingredientId,
    nama: nama,
    kategori: kategori,
    harga: harga ?? this.harga,
    satuan: satuan,
    stok: stok,
    stokMinimum: stokMinimum,
    stokText: stokText,
    utama: utama ?? this.utama,
  );
}

class DetailSupplierPage extends StatefulWidget {
  /// id dokumen supplier di Firestore
  final String supplierId;

  const DetailSupplierPage({super.key, required this.supplierId});

  @override
  State<DetailSupplierPage> createState() => _DetailSupplierPageState();
}

class _DetailSupplierPageState extends State<DetailSupplierPage> {
  SupplierData? _supplier;
  List<SupplierItem> _items = [];
  List<Ingredient> _ingredients = [];

  bool _supplierLoaded = false;
  bool _itemsLoaded = false;
  bool _ingredientsLoaded = false;
  String? _error;

  final List<StreamSubscription<dynamic>> _subs = [];

  @override
  void initState() {
    super.initState();
    _subs.add(
      SupplierService.instance.watchOne(widget.supplierId).listen(
            (s) {
          if (!mounted) return;
          setState(() {
            _supplier = s;
            _supplierLoaded = true;
          });
        },
        onError: _onError,
      ),
    );
    _subs.add(
      SupplierService.instance.watchItems(widget.supplierId).listen(
            (list) {
          if (!mounted) return;
          setState(() {
            _items = list;
            _itemsLoaded = true;
          });
        },
        onError: _onError,
      ),
    );
    _subs.add(
      IngredientService.instance.watchAll().listen(
            (list) {
          if (!mounted) return;
          setState(() {
            _ingredients = list;
            _ingredientsLoaded = true;
          });
        },
        onError: _onError,
      ),
    );
  }

  void _onError(Object e) {
    debugPrint('detail supplier error: $e');
    if (!mounted) return;
    setState(() => _error = 'Gagal memuat data supplier.');
  }

  @override
  void dispose() {
    for (final s in _subs) {
      s.cancel();
    }
    super.dispose();
  }

  /// Gabungkan item supplier dengan data bahan (nama, kategori, satuan, stok).
  List<BahanSupplier> get _bahan {
    final byId = {for (final i in _ingredients) i.id: i};
    final list = <BahanSupplier>[];

    for (final it in _items) {
      final ing = byId[it.ingredientId];
      if (ing == null) continue; // bahan sudah dihapus
      list.add(
        BahanSupplier(
          ingredientId: ing.id,
          nama: ing.name,
          kategori: ing.category.label,
          harga: it.price,
          satuan: ing.unit.label,
          stok: ing.totalStock / ing.unit.factor,
          stokMinimum: ing.minStock / ing.unit.factor,
          stokText: formatQty(ing.totalStock, ing.unit),
          utama: ing.mainSupplierId == widget.supplierId,
        ),
      );
    }
    list.sort((a, b) => a.nama.toLowerCase().compareTo(b.nama.toLowerCase()));
    return list;
  }

  void _pesan(String teks) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(teks)));
  }

  // ------------------------------------------------------------
  // BUILD
  // ------------------------------------------------------------
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
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_error != null) return _pesanTengah(_error!);

    if (!(_supplierLoaded && _itemsLoaded && _ingredientsLoaded)) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.orangeAccent),
      );
    }

    final s = _supplier;
    if (s == null || s.isDeleted) return _pesanTengah('Supplier tidak ditemukan.');

    final bahan = _bahan;
    final punyaBahan = bahan.isNotEmpty;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(12, 18, 12, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfil(s),
                const SizedBox(height: 16),
                _buildTombolKontak(),
                const SizedBox(height: 22),
                _buildInfoKontak(s),
                const SizedBox(height: 22),
                _buildBahan(bahan),
              ],
            ),
          ),
        ),
        _buildBottomPO(punyaBahan),
      ],
    );
  }

  Widget _pesanTengah(String teks) {
    return Center(
      child: Text(teks,
          style: const TextStyle(fontSize: 14, color: AppColors.mutedText)),
    );
  }

  // ===== Profil =====
  Widget _buildProfil(SupplierData s) {
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
            child: Text(supplierInitials(s.name),
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
                Text(s.name,
                    style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark)),
                const SizedBox(height: 2),
                Text('PIC: ${s.pic} · ${s.phone}',
                    style: const TextStyle(
                        fontSize: 12.5, color: AppColors.neutralText)),
                const SizedBox(height: 4),
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: s.isActive
                        ? AppColors.safeTagBg
                        : AppColors.exhaustedStatusBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(s.isActive ? Icons.check : Icons.close,
                          size: 11,
                          color:
                          s.isActive ? AppColors.green : AppColors.red),
                      const SizedBox(width: 3),
                      Text(s.isActive ? 'Aktif' : 'Nonaktif',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: s.isActive
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
            // TODO: buka dialer (url_launcher: tel:)
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
  Widget _buildInfoKontak(SupplierData s) {
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
              // TODO (tahap edit): buka halaman Edit Supplier
              onTap: () => _pesan('Edit supplier dikerjakan di tahap berikutnya'),
              behavior: HitTestBehavior.opaque,
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(Icons.edit_outlined,
                    size: 22, color: AppColors.sectionText),
              ),
            ),
          ),
          const SizedBox(height: 14),
          baris('PIC', s.pic),
          baris('Telepon', s.phone),
          baris('Email', s.email),
          baris('Alamat', s.address),
          baris('Termin Pembayaran', s.paymentTerm),
        ],
      ),
    );
  }

  // ===== Bahan yang Disuplai =====
  Widget _buildBahan(List<BahanSupplier> bahan) {
    final perluDipesan =
        bahan.where((b) => b.status != StatusStok.aman).length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          _sectionTitle(
            'Bahan yang Disuplai (${bahan.length})',
            GestureDetector(
              // TODO (tahap edit): tambah bahan ke supplier ini
              onTap: () =>
                  _pesan('Menambah bahan ke supplier dikerjakan di tahap berikutnya'),
              child: const Text('+ Tambah',
                  style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w500,
                      color: AppColors.sectionText)),
            ),
          ),
          const SizedBox(height: 14),
          if (bahan.isNotEmpty) ...[
            if (perluDipesan > 0) _buildBannerInfo(perluDipesan),
            ...bahan.asMap().entries.map((e) => _BahanTile(
              bahan: e.value,
              isLast: e.key == bahan.length - 1,
              // TODO (tahap edit): buka popup Ubah Harga
              onTap: () =>
                  _pesan('Ubah harga dikerjakan di tahap berikutnya'),
            )),
          ] else
            _buildEmptyState(),
        ],
      ),
    );
  }

  Widget _buildBannerInfo(int jumlah) {
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
          Text('$jumlah bahan perlu dipesan',
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
            onPressed: () =>
                _pesan('Menambah bahan ke supplier dikerjakan di tahap berikutnya'),
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
                    ? () => _pesan('Pembuatan PO dikerjakan di tahap berikutnya')
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
                  Text('${formatRupiah(bahan.harga)} / ${bahan.satuan}',
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
          Text('$label (${bahan.stokLabel})',
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
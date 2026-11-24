import 'package:flutter/material.dart';

import '../kasir/kasir_theme.dart';
import '../kasir/kasir_widgets.dart';
import 'kitchen_model.dart';
import 'request_restock.dart';

class InformasiBahanPage extends StatelessWidget {
  final BahanStok bahan;
  const InformasiBahanPage({super.key, required this.bahan});

  @override
  Widget build(BuildContext context) {
    final batches = bahan.batchTerurut;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const KasirTopBar(title: 'Informasi Bahan'),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(25, 19, 25, 30),
              children: [
                Stack(
                  children: [
                    KImage(
                      bahan.gambar,
                      height: 168,
                      radius: 8,
                      width: double.infinity,
                    ),
                    Positioned(
                      top: 6,
                      right: 6,
                      child: _StatusLabel(status: bahan.status),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(bahan.nama, style: ks(24, w: FontWeight.w800, h: 1.2)),
                Text(bahan.kategori, style: ks(11, c: KColors.inkSoft)),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x14000000),
                        blurRadius: 6,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _infoRow(
                        'Stok Minimal',
                        '${fmtQty(bahan.minimum)} ${bahan.satuan}',
                        border: true,
                      ),
                      _infoRow(
                        'Batas Kadaluwarsa',
                        '${bahan.batasKadaluwarsaHari} hari',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 26),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Persediaan',
                        style: ks(20, w: FontWeight.w700, c: KColors.navy),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => RequestRestockPage(bahanAwal: bahan),
                        ),
                      ),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: KColors.amber,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Container(height: 1, color: KColors.border),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: KColors.creamField,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total ${fmtQty(bahan.total)} ${bahan.satuan} dalam ${batches.length} batch',
                        style: ks(15, w: FontWeight.w600),
                      ),
                      Text(
                        'Diurutkan dari tanggal kadaluwarsa terdekat',
                        style: ks(11, c: KColors.rust),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                if (batches.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Text(
                        'Belum ada persediaan',
                        style: ks(14, c: KColors.muted),
                      ),
                    ),
                  ),
                for (final b in batches) _BatchCard(bahan: bahan, batch: b),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value, {bool border = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: border
            ? const Border(bottom: BorderSide(color: KColors.divider))
            : null,
      ),
      child: Row(
        children: [
          Text(label, style: ks(13, c: KColors.rust)),
          const Spacer(),
          Text(value, style: ks(13, w: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _StatusLabel extends StatelessWidget {
  final StokStatus status;
  const _StatusLabel({required this.status});

  @override
  Widget build(BuildContext context) {
    final (bg, fg, icon) = switch (status) {
      StokStatus.aman => (
        const Color(0xFFC9F2D3),
        const Color(0xFF14663A),
        Icons.check_circle,
      ),
      StokStatus.menipis => (
        const Color(0xFFFFEFB5),
        const Color(0xFF8A5A00),
        Icons.warning_rounded,
      ),
      StokStatus.habis => (KColors.redBg, KColors.red, Icons.cancel),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: fg),
          const SizedBox(width: 5),
          Text(
            'Stok ${status.label}',
            style: ks(11, w: FontWeight.w700, c: fg),
          ),
        ],
      ),
    );
  }
}

class _BatchCard extends StatelessWidget {
  final BahanStok bahan;
  final Batch batch;
  const _BatchCard({required this.bahan, required this.batch});

  @override
  Widget build(BuildContext context) {
    final menipis = batch.stok <= bahan.minimum;
    final expired = batch.akanKadaluwarsa;
    final adaPeringatan = menipis || expired;

    final sisa = batch.sisaHari;
    final teksKadaluwarsa = sisa < 0
        ? 'Sudah kadaluwarsa'
        : (sisa <= 1
              ? 'Kadaluwarsa dalam 24 jam'
              : 'Kadaluwarsa dalam $sisa hari');

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: adaPeringatan ? KColors.brown : KColors.amber,
          width: 0.8,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            child: Column(
              children: [
                Row(
                  children: [
                    Text(batch.nama, style: ks(16, w: FontWeight.w700)),
                    const SizedBox(width: 10),
                    if (menipis) ...[
                      _warnPill('Stok Menipis'),
                      const SizedBox(width: 6),
                    ],
                    if (expired) _warnPill('Akan Kadaluwarsa'),
                  ],
                ),
                const SizedBox(height: 10),
                _row('Stok', '${fmtQty(batch.stok)} ${bahan.satuan}'),
                const SizedBox(height: 6),
                _row('Baik Sebelum', formatTanggalPanjang(batch.baikSebelum)),
              ],
            ),
          ),
          if (adaPeringatan)
            Container(
              width: double.infinity,
              color: KColors.peach,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (menipis)
                    _alert(
                      'Stok Mencapai Batas Minimal',
                      'Segera ajukan restock bahan.',
                    ),
                  if (menipis && expired) const SizedBox(height: 10),
                  if (expired)
                    _alert(teksKadaluwarsa, 'Gunakan batch ini lebih dulu.'),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _row(String label, String value) => Row(
    children: [
      Text(label, style: ks(14, c: KColors.inkSoft)),
      const Spacer(),
      Text(value, style: ks(14, w: FontWeight.w700)),
    ],
  );

  Widget _warnPill(String text) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
    decoration: BoxDecoration(
      color: KColors.peach,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.warning_amber_rounded,
          size: 12,
          color: KColors.rustDark,
        ),
        const SizedBox(width: 3),
        Text(
          text,
          style: ks(10, w: FontWeight.w700, c: KColors.rustDark),
        ),
      ],
    ),
  );

  Widget _alert(String judul, String isi) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Padding(
        padding: EdgeInsets.only(top: 1),
        child: Icon(Icons.error, size: 18, color: KColors.rustDark),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              judul,
              style: ks(12, w: FontWeight.w700, c: KColors.rustDark),
            ),
            Text(isi, style: ks(12, c: KColors.rustDark)),
          ],
        ),
      ),
    ],
  );
}

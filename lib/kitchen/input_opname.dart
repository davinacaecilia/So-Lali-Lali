import 'package:flutter/material.dart';

import '../kasir/kasir_theme.dart';
import '../kasir/kasir_widgets.dart';
import 'detail_stock.dart';
import 'kitchen_model.dart';
import 'kitchen_widgets.dart';
import 'review_hasil_opname.dart';
import 'scan_qr.dart';

/// Input Stock Opname: hitung fisik tiap bahan (manual atau scan QR).
class InputOpnamePage extends StatefulWidget {
  final OpnameSesi sesi;
  const InputOpnamePage({super.key, required this.sesi});

  @override
  State<InputOpnamePage> createState() => _InputOpnamePageState();
}

class _InputOpnamePageState extends State<InputOpnamePage> {
  final _store = KitchenStore.instance;
  String _query = '';
  String? _kategori; // null = Semua

  Future<void> _isi(BahanStok b) async {
    final v = await showDetailStockSheet(
      context,
      bahan: b,
      awal: widget.sesi.entries[b.id]?.fisik,
    );
    if (v != null) _store.simpanOpname(widget.sesi, b, v);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ListenableBuilder(
        listenable: _store,
        builder: (context, _) {
          final total = _store.bahan.length;
          final terisi = widget.sesi.terisi;
          final selesai = terisi >= total;
          final list = _store.bahan
              .where((b) => _kategori == null || b.kategori == _kategori)
              .where((b) => b.nama.toLowerCase().contains(_query.toLowerCase()))
              .toList();

          return Column(
            children: [
              const KasirTopBar(title: 'Input Stock Opname'),
              Padding(
                padding: const EdgeInsets.fromLTRB(25, 14, 25, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('Progress Opname', style: ks(13, c: KColors.brown)),
                        const Spacer(),
                        Text('$terisi/$total Bahan',
                            style: ks(15, w: FontWeight.w800, c: const Color(0xFF8A5A00))),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: total == 0 ? 0 : terisi / total,
                        minHeight: 9,
                        backgroundColor: const Color(0xFFF3DFC0),
                        valueColor: const AlwaysStoppedAnimation(KColors.amber),
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => ScanQrPage(sesi: widget.sesi)),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: KColors.navyDark),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        icon: const Icon(Icons.qr_code_scanner, color: KColors.navyDark),
                        label: Text('Scan Barcode',
                            style: ks(16, w: FontWeight.w700, c: KColors.navyDark)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    KSearchField(
                      hint: 'Cari nama bahan',
                      onChanged: (v) => setState(() => _query = v),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
              SizedBox(
                height: 34,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  children: [
                    _chip('Semua', null),
                    for (final k in kKategoriBahan) _chip(k, k),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Expanded(
                child: list.isEmpty
                    ? Center(
                        child: Text('Bahan tidak ditemukan', style: ks(14, c: KColors.muted)))
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 12),
                        itemCount: list.length,
                        itemBuilder: (context, i) => _BahanRow(
                          bahan: list[i],
                          sudah: widget.sesi.entries.containsKey(list[i].id),
                          onTap: () => _isi(list[i]),
                        ),
                      ),
              ),
              // Muncul setelah semua bahan selesai dihitung.
              if (selesai)
                Padding(
                  padding: const EdgeInsets.fromLTRB(25, 8, 25, 0),
                  child: SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: KButton(
                        label: 'Review Hasil Opname',
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => ReviewHasilOpnamePage(sesi: widget.sesi)),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _chip(String label, String? value) {
    final on = _kategori == value;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: GestureDetector(
        onTap: () => setState(() => _kategori = value),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: on ? KColors.navyLight : KColors.creamField,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(label,
              style: ks(13, w: FontWeight.w600, c: on ? Colors.white : KColors.brown)),
        ),
      ),
    );
  }
}

class _BahanRow extends StatelessWidget {
  final BahanStok bahan;
  final bool sudah;
  final VoidCallback onTap;
  const _BahanRow({required this.bahan, required this.sudah, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 33, vertical: 10),
        child: Row(
          children: [
            BahanIcon(bahan.ikon),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(bahan.nama,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: ks(16, w: FontWeight.w600)),
                      ),
                      if (sudah) ...[
                        const SizedBox(width: 8),
                        const Icon(Icons.check_circle, size: 20, color: Color(0xFF1E8E4E)),
                      ],
                    ],
                  ),
                  Text(bahan.kategori, style: ks(11, c: KColors.rust)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('Stok Sistem', style: ks(11, c: KColors.inkSoft)),
                Text('${fmtQty(bahan.total)} ${satuanPendek(bahan.satuan)}',
                    style: ks(16, w: FontWeight.w700)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

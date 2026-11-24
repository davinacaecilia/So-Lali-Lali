import 'package:flutter/material.dart';

import '../kasir/kasir_theme.dart';
import '../kasir/kasir_widgets.dart';
import 'filter_bahan.dart';
import 'informasi_bahan.dart';
import 'kitchen_model.dart';
import 'kitchen_widgets.dart';
import 'request_restock.dart';
import 'riwayat_restock.dart';

class StokPage extends StatefulWidget {
  const StokPage({super.key});

  @override
  State<StokPage> createState() => _StokPageState();
}

class _StokPageState extends State<StokPage> {
  String _query = '';
  BahanFilter _filter = const BahanFilter();

  @override
  Widget build(BuildContext context) {
    final store = KitchenStore.instance;
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final list = _filter
            .terapkan(store.bahan)
            .where((b) => b.nama.toLowerCase().contains(_query.toLowerCase()))
            .toList();

        return Stack(
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(25, 23, 25, 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: KSearchField(
                          hint: 'Cari nama bahan',
                          onChanged: (v) => setState(() => _query = v),
                        ),
                      ),
                      const SizedBox(width: 9),
                      KFilterButton(onTap: () async {
                        final res = await showFilterBahanSheet(context, _filter);
                        if (res != null) setState(() => _filter = res);
                      }),
                    ],
                  ),
                ),
                // Banner ke riwayat request restock
                Padding(
                  padding: const EdgeInsets.fromLTRB(25, 0, 25, 8),
                  child: Material(
                    color: KColors.navy,
                    borderRadius: BorderRadius.circular(4),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(4),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const RiwayatRestockPage()),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text('Lihat Riwayat Request Restock',
                                  style: ks(14, w: FontWeight.w700, c: Colors.white)),
                            ),
                            const Icon(Icons.chevron_right, color: Colors.white, size: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: list.isEmpty
                      ? Center(
                          child: Text('Bahan tidak ditemukan',
                              style: ks(14, c: KColors.muted)))
                      : ListView.builder(
                          padding: const EdgeInsets.only(bottom: 96),
                          itemCount: list.length,
                          itemBuilder: (context, i) => _BahanRow(bahan: list[i]),
                        ),
                ),
              ],
            ),
            Positioned(
              right: 25,
              bottom: 24,
              child: KFab(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RequestRestockPage()),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _BahanRow extends StatelessWidget {
  final BahanStok bahan;
  const _BahanRow({required this.bahan});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => InformasiBahanPage(bahan: bahan)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 33, vertical: 12),
        child: Row(
          children: [
            BahanIcon(bahan.ikon),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(bahan.nama,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: ks(16, w: FontWeight.w600, h: 1.25)),
                  Text(bahan.kategori, style: ks(12, c: KColors.rust)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                StokBadge(status: bahan.status),
                const SizedBox(height: 4),
                Text('${fmtQty(bahan.total)} ${bahan.satuan}',
                    style: ks(16, w: FontWeight.w700, c: stokColor(bahan.status))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

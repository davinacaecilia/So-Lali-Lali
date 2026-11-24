import 'package:flutter/material.dart';

import '../kasir/kasir_model.dart'; // formatWaktu
import '../kasir/kasir_theme.dart';
import '../kasir/kasir_widgets.dart';
import 'filter_waste.dart';
import 'informasi_waste.dart';
import 'kitchen_model.dart';
import 'kitchen_widgets.dart';
import 'tambah_waste.dart';

class WastePage extends StatefulWidget {
  const WastePage({super.key});

  @override
  State<WastePage> createState() => _WastePageState();
}

class _WastePageState extends State<WastePage> {
  String _query = '';
  WasteFilter _filter = const WasteFilter();

  @override
  Widget build(BuildContext context) {
    final store = KitchenStore.instance;
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final list = store.waste
            .where(_filter.cocok)
            .where((w) => w.bahan.nama.toLowerCase().contains(_query.toLowerCase()))
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
                        final res = await showFilterWasteSheet(context, _filter);
                        if (res != null) setState(() => _filter = res);
                      }),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.fromLTRB(25, 0, 25, 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: KColors.peach,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, size: 26, color: Color(0xFF8A5A00)),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text.rich(
                          TextSpan(
                            style: ks(13, w: FontWeight.w500, c: const Color(0xFF8A5A00), h: 1.4),
                            children: const [
                              TextSpan(
                                text: 'Barang yang kadaluwarsa',
                                style: TextStyle(fontWeight: FontWeight.w800),
                              ),
                              TextSpan(text: ' akan otomatis dicatat sistem sebagai waste'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: list.isEmpty
                      ? Center(
                          child: Text('Data waste tidak ditemukan',
                              style: ks(14, c: KColors.muted)))
                      : ListView.builder(
                          padding: const EdgeInsets.only(bottom: 96),
                          itemCount: list.length,
                          itemBuilder: (context, i) => _WasteRow(waste: list[i]),
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
                  MaterialPageRoute(builder: (_) => const TambahWastePage()),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _WasteRow extends StatelessWidget {
  final WasteRecord waste;
  const _WasteRow({required this.waste});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => InformasiWastePage(waste: waste)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
        child: Row(
          children: [
            BahanIcon(waste.bahan.ikon),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(waste.bahan.nama,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: ks(16, w: FontWeight.w600)),
                  Text(formatWaktu(waste.waktu), style: ks(11, c: KColors.inkSoft)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                KPill.status(waste.keterangan, size: 12),
                const SizedBox(height: 2),
                Text('${fmtQty(waste.jumlah)} ${waste.bahan.satuan}',
                    style: ks(16, w: FontWeight.w700, c: KColors.amber)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

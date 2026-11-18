import 'package:flutter/material.dart';

import 'detail_transaksi.dart';
import 'kasir_model.dart';
import 'kasir_theme.dart';
import 'kasir_widgets.dart';
import 'riwayat_filter.dart';

class RiwayatPage extends StatefulWidget {
  const RiwayatPage({super.key});

  @override
  State<RiwayatPage> createState() => _RiwayatPageState();
}

class _RiwayatPageState extends State<RiwayatPage> {
  String _query = '';
  RiwayatFilter _filter = const RiwayatFilter();

  @override
  Widget build(BuildContext context) {
    final store = KasirStore.instance;
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final list = store.riwayat
            .where((t) => _filter.cocok(t)) // ← tambah
            .where((t) => t.kode.toLowerCase().contains(_query.toLowerCase()))
            .toList();

        // Susun daftar + judul grup ("Hari Ini", "28 Nov 2026", ...).
        final children = <Widget>[];
        String? lastLabel;
        for (var i = 0; i < list.length; i++) {
          final t = list[i];
          final label = isToday(t.waktu) ? 'Hari Ini' : formatTanggal(t.waktu);
          if (label != lastLabel) {
            children.add(
              Padding(
                padding: EdgeInsets.fromLTRB(
                  25,
                  lastLabel == null ? 8 : 22,
                  25,
                  6,
                ),
                child: Text(
                  label,
                  style: ks(17, w: FontWeight.w700, c: KColors.navy),
                ),
              ),
            );
            lastLabel = label;
          }
          children.add(_TrxRow(trx: t));
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(25, 23, 25, 10),
              child: Row(
                children: [
                  Expanded(
                    child: KSearchField(
                      hint: 'Cari nomor transaksi',
                      onChanged: (v) => setState(() => _query = v),
                    ),
                  ),
                  const SizedBox(width: 9),
                  KFilterButton(
                    onTap: () async {
                      final res = await showRiwayatFilterSheet(
                        context,
                        _filter,
                      );
                      if (res != null) setState(() => _filter = res);
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: list.isEmpty
                  ? Center(
                      child: Text(
                        'Transaksi tidak ditemukan',
                        style: ks(14, c: KColors.muted),
                      ),
                    )
                  : ListView(
                      padding: const EdgeInsets.only(bottom: 16),
                      children: children,
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _TrxRow extends StatelessWidget {
  final Transaksi trx;
  const _TrxRow({required this.trx});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => DetailTransaksiPage(trx: trx)),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 25),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: KColors.border)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(trx.kode, style: ks(16, w: FontWeight.w700)),
                  Text(
                    formatWaktu(trx.waktu),
                    style: ks(11, c: KColors.inkSoft),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  rupiah(trx.total),
                  style: ks(16, w: FontWeight.w700, c: KColors.amber),
                ),
                Text(
                  '${trx.jumlahItem} Item',
                  style: ks(11, c: KColors.inkSoft),
                ),
              ],
            ),
            const SizedBox(width: 10),
            const Icon(Icons.chevron_right, size: 20, color: KColors.muted),
          ],
        ),
      ),
    );
  }
}

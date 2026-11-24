import 'package:flutter/material.dart';

import '../kasir/kasir_model.dart'; // formatWaktu (format singkat: 29 Nov 2026, 19:41)
import '../kasir/kasir_theme.dart';
import '../kasir/kasir_widgets.dart';
import 'detail_request.dart';
import 'filter_riwayat_restock.dart';
import 'kitchen_model.dart';
import 'kitchen_widgets.dart';

class RiwayatRestockPage extends StatefulWidget {
  const RiwayatRestockPage({super.key});

  @override
  State<RiwayatRestockPage> createState() => _RiwayatRestockPageState();
}

class _RiwayatRestockPageState extends State<RiwayatRestockPage> {
  String _query = '';
  RestockFilter _filter = const RestockFilter();

  @override
  Widget build(BuildContext context) {
    final store = KitchenStore.instance;
    return Scaffold(
      backgroundColor: Colors.white,
      body: ListenableBuilder(
        listenable: store,
        builder: (context, _) {
          final list = store.requests
              .where(_filter.cocok)
              .where((r) => r.kode.toLowerCase().contains(_query.toLowerCase()))
              .toList();
          return Column(
            children: [
              const KasirTopBar(title: 'Riwayat Request Restock'),
              Padding(
                padding: const EdgeInsets.fromLTRB(25, 23, 25, 10),
                child: Row(
                  children: [
                    Expanded(
                      child: KSearchField(
                        hint: 'Cari nomor request',
                        onChanged: (v) => setState(() => _query = v),
                      ),
                    ),
                    const SizedBox(width: 9),
                    KFilterButton(onTap: () async {
                      final res = await showFilterRiwayatRestockSheet(context, _filter);
                      if (res != null) setState(() => _filter = res);
                    }),
                  ],
                ),
              ),
              Expanded(
                child: list.isEmpty
                    ? Center(
                        child: Text('Request tidak ditemukan',
                            style: ks(14, c: KColors.muted)))
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 16),
                        itemCount: list.length,
                        itemBuilder: (context, i) => _Row(req: list[i]),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final RestockRequest req;
  const _Row({required this.req});

  @override
  Widget build(BuildContext context) {
    final jumlahItem = req.items.length;
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => DetailRequestPage(request: req)),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 25),
        padding: const EdgeInsets.fromLTRB(12, 12, 0, 12),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: KColors.border)),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(req.kode, style: ks(16, w: FontWeight.w700)),
                      Text(formatWaktu(req.waktu), style: ks(11, c: KColors.inkSoft)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    KPill.status(req.status.label, size: 12),
                    const SizedBox(height: 2),
                    Text('$jumlahItem Item', style: ks(11, c: KColors.inkSoft)),
                  ],
                ),
                const SizedBox(width: 6),
                const Icon(Icons.chevron_right, size: 20, color: KColors.muted),
              ],
            ),
            if (req.status == RestockStatus.selesai && req.poDibuat != null) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(right: 24),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE6C8),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'PO dibuat pada ${formatWaktu(req.poDibuat!)}',
                  style: ks(11, w: FontWeight.w700, c: const Color(0xFF8A5A00)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

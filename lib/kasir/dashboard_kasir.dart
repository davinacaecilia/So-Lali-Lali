import 'package:flutter/material.dart';

import 'detail_transaksi.dart';
import 'kasir_model.dart';
import 'kasir_theme.dart';
import 'pilih_menu.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final store = KasirStore.instance;
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final hariIni = store.riwayat.where((t) => isToday(t.waktu)).toList();
        final terjual = hariIni.fold<int>(0, (s, t) => s + t.jumlahItem);
        final terbaru = store.riwayat.take(5).toList();

        return ListView(
          padding: const EdgeInsets.fromLTRB(25, 19, 25, 24),
          children: [
            _banner(context),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    label: 'Transaksi Hari Ini',
                    value: '${hariIni.length}',
                    delta: '- 3,12% dari kemarin',
                    naik: false,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _StatCard(
                    label: 'Menu Terjual',
                    value: '$terjual',
                    unit: 'porsi',
                    delta: '+ 3,12% dari kemarin',
                    naik: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            Container(
              padding: const EdgeInsets.fromLTRB(22, 22, 22, 10),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: KColors.border),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        'Aktivitas Terbaru',
                        style: ks(16, w: FontWeight.w700, c: KColors.brown),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => store.tab.value = 2,
                        child: Text(
                          'Lihat Semua',
                          style: ks(13, w: FontWeight.w500, c: KColors.amber),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  for (final t in terbaru) _ActivityRow(trx: t),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _banner(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PilihMenuPage()),
        );
      },
      child: Container(
        padding: const EdgeInsets.fromLTRB(25, 28, 25, 24),
        decoration: BoxDecoration(
          color: KColors.navy,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Buat Transaksi Baru',
                    style: ks(22, w: FontWeight.w700, c: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF9FB0D6),
                      borderRadius: BorderRadius.circular(
                        4,
                      ), // ubah angkanya kalau mau lebih bulat
                    ),
                    child: Text(
                      'Siap Melayani Pelanggan Hari Ini?',
                      style: ks(12, w: FontWeight.w500, c: KColors.navy),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: KColors.sand,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.add, color: KColors.navyDark, size: 26),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String? unit;
  final String delta;
  final bool naik;
  const _StatCard({
    required this.label,
    required this.value,
    this.unit,
    required this.delta,
    required this.naik,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 18, 12, 14),
      decoration: BoxDecoration(
        color: KColors.creamCard,
        border: Border.all(color: KColors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: ks(13, c: KColors.inkSoft)),
          const SizedBox(height: 6),
          Text.rich(
            TextSpan(
              text: value,
              style: ks(30, w: FontWeight.w800, c: KColors.amber),
              children: [
                if (unit != null)
                  TextSpan(
                    text: ' $unit',
                    style: ks(16, w: FontWeight.w700, c: KColors.brown),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            delta,
            style: ks(
              11,
              w: FontWeight.w500,
              c: naik ? KColors.green : KColors.red,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityRow extends StatelessWidget {
  final Transaksi trx;
  const _ActivityRow({required this.trx});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => DetailTransaksiPage(trx: trx)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: KColors.iconBg,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Icon(
                Icons.assignment_outlined,
                color: KColors.brown,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(trx.kode, style: ks(15, w: FontWeight.w700)),
                  Text(
                    '${trx.items.length} Menu',
                    style: ks(13, c: KColors.inkSoft),
                  ),
                ],
              ),
            ),
            Text(
              rupiah(trx.total, space: false),
              style: ks(15, w: FontWeight.w700, c: KColors.navyDark),
            ),
          ],
        ),
      ),
    );
  }
}

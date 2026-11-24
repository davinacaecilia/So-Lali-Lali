import 'package:flutter/material.dart';

import '../kasir/kasir_theme.dart';
import 'informasi_waste.dart';
import 'kitchen_model.dart';
import 'kitchen_widgets.dart';
import 'detail_hasil_opname.dart';
import 'detail_request.dart';
import 'request_restock.dart';
import 'tambah_waste.dart';

class DashboardKitchenPage extends StatelessWidget {
  const DashboardKitchenPage({super.key});

  @override
  Widget build(BuildContext context) {
    final store = KitchenStore.instance;
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final aktivitas = store.aktivitas.take(5).toList();
        return ListView(
          padding: const EdgeInsets.fromLTRB(25, 22, 25, 24),
          children: [
            Row(
              children: [
                _QuickAction(
                  icon: Icons.photo_camera_outlined,
                  label: 'Catat\nWaste',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const TambahWastePage()),
                  ),
                ),
                _QuickAction(
                  icon: Icons.assignment_outlined,
                  label: 'Opname\nHarian',
                  onTap: () => store.tab.value = 4,
                ),
                _QuickAction(
                  icon: Icons.add,
                  label: 'Request\nRestock',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RequestRestockPage()),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    label: 'Stock Menipis',
                    value: '${store.jumlahMenipis}',
                    caption: 'dibawah minimum',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _StatCard(
                    label: 'Hampir Expired',
                    value: '${store.jumlahHampirExpired}',
                    caption: 'dalam 7 hari',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            Container(
              padding: const EdgeInsets.fromLTRB(22, 22, 22, 12),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: KColors.border),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Aktivitas Terbaru',
                      style: ks(16, w: FontWeight.w700, c: KColors.brown)),
                  const SizedBox(height: 14),
                  for (final a in aktivitas) _AktivitasRow(item: a),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _QuickAction({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: KColors.navy,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: Colors.white, size: 30),
            ),
            const SizedBox(height: 8),
            Text(label,
                textAlign: TextAlign.center, style: ks(12, w: FontWeight.w700, h: 1.2)),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String caption;
  const _StatCard({required this.label, required this.value, required this.caption});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 22, 12, 18),
      decoration: BoxDecoration(
        color: KColors.creamCard,
        border: Border.all(color: KColors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: ks(14, c: KColors.inkSoft)),
          const SizedBox(height: 6),
          Text(value, style: ks(30, w: FontWeight.w800, c: KColors.amber)),
          const SizedBox(height: 4),
          Text(caption, style: ks(11, w: FontWeight.w600, c: KColors.red)),
        ],
      ),
    );
  }
}

class _AktivitasRow extends StatelessWidget {
  final Aktivitas item;
  const _AktivitasRow({required this.item});

  IconData get _ikon => switch (item.jenis) {
        AktivitasJenis.restock => Icons.inventory_2,
        AktivitasJenis.waste => Icons.delete_outline,
        AktivitasJenis.opname => Icons.assignment_outlined,
      };

  void _buka(BuildContext context) {
    final ref = item.ref;
    if (ref is RestockRequest) {
      Navigator.push(context,
          MaterialPageRoute(builder: (_) => DetailRequestPage(request: ref)));
    } else if (ref is WasteRecord) {
      Navigator.push(context,
          MaterialPageRoute(builder: (_) => InformasiWastePage(waste: ref)));
    } else if (ref is OpnameSesi) {
      Navigator.push(context,
          MaterialPageRoute(builder: (_) => DetailHasilOpnamePage(sesi: ref)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: item.ref == null ? null : () => _buka(context),
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
              child: Icon(_ikon, color: KColors.brown, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.judul,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: ks(15, w: FontWeight.w700)),
                  Text(item.subjudul,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: ks(12, c: KColors.inkSoft)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (item.status != null)
                  KPill.status(item.status!)
                else if (item.nilai != null)
                  Text(item.nilai!,
                      style: ks(15, w: FontWeight.w800, c: KColors.navyDark)),
                const SizedBox(height: 2),
                Text(formatJamWib(item.waktu), style: ks(12, c: KColors.inkSoft)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

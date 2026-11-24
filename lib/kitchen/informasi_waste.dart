import 'package:flutter/material.dart';

import '../kasir/kasir_model.dart'; // formatWaktu
import '../kasir/kasir_theme.dart';
import '../kasir/kasir_widgets.dart';
import 'kitchen_model.dart';
import 'kitchen_widgets.dart';

class InformasiWastePage extends StatelessWidget {
  final WasteRecord waste;
  const InformasiWastePage({super.key, required this.waste});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const KasirTopBar(title: 'Informasi Waste'),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(25, 19, 25, 30),
              children: [
                KImage(waste.bahan.gambar, height: 168, radius: 8),
                const SizedBox(height: 14),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(waste.bahan.nama, style: ks(24, w: FontWeight.w800)),
                          Text(formatWaktu(waste.waktu), style: ks(11, c: KColors.inkSoft)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    KPill.status(waste.keterangan, size: 12),
                  ],
                ),
                const SizedBox(height: 10),
                Container(height: 1, color: const Color(0xFFDDD6CC)),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Column(
                    children: [
                      _row('Jumlah', '${fmtQty(waste.jumlah)} ${waste.bahan.satuan}'),
                      _row('Batch Persediaan', waste.batch),
                      _row('Keterangan', waste.keterangan),
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

  Widget _row(String label, String value) => Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: KColors.divider)),
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

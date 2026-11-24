import 'package:flutter/material.dart';

import '../kasir/kasir_model.dart';
import '../kasir/kasir_theme.dart';
import '../kasir/kasir_widgets.dart';
import 'kitchen_widgets.dart';

class InformasiMenuKitchenPage extends StatelessWidget {
  final MenuProduk menu;
  const InformasiMenuKitchenPage({super.key, required this.menu});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const KasirTopBar(title: 'Informasi Menu'),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(25, 19, 25, 30),
              children: [
                KImage(menu.gambar, height: 168, radius: 8),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(menu.nama, style: ks(24, w: FontWeight.w800)),
                          Text(menu.kategori, style: ks(11, c: KColors.inkSoft)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 103,
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        color: menu.tersedia ? KColors.greenBg : KColors.redBg,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        menu.tersedia ? 'Tersedia' : 'Tidak Tersedia',
                        textAlign: TextAlign.center,
                        style: ks(12,
                            w: FontWeight.w500,
                            c: menu.tersedia ? KColors.green : KColors.red),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                const SectionTitle('Rincian Resep', size: 20, lineColor: KColors.border),
                const SizedBox(height: 14),
                for (final b in menu.resep)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 13),
                    child: NamaQtyRow(nama: b.nama, qty: b.takaran),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

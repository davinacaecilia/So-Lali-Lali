import 'package:flutter/material.dart';

import 'kasir_model.dart';
import 'kasir_theme.dart';
import 'kasir_widgets.dart';

class InformasiMenuPage extends StatelessWidget {
  final MenuProduk menu;
  const InformasiMenuPage({super.key, required this.menu});

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
                          Text('ID: ${menu.id}', style: ks(11, c: KColors.inkSoft)),
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
                        style: ks(12, w: FontWeight.w500,
                            c: menu.tersedia ? KColors.green : KColors.red),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                const SectionTitle('Detail Menu', size: 20, lineColor: KColors.border),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: const [
                      BoxShadow(color: Color(0x14000000), blurRadius: 6, offset: Offset(0, 1)),
                    ],
                  ),
                  child: Column(
                    children: [
                      _detailRow('Nama Menu', menu.nama, border: true),
                      _detailRow('Kategori Menu', menu.kategori, border: true),
                      _detailRow('Harga Jual', rupiah(menu.harga)),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                const SectionTitle('Rincian Resep', size: 20, lineColor: KColors.border),
                const SizedBox(height: 14),
                for (final b in menu.resep) _resepRow(b),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value, {bool border = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 13),
      decoration: BoxDecoration(
        border: border ? const Border(bottom: BorderSide(color: KColors.divider)) : null,
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

  Widget _resepRow(Bahan b) {
    return Container(
      height: 56,
      margin: const EdgeInsets.only(bottom: 13),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: KColors.brown, width: 0.8),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(b.nama, style: ks(15)),
            ),
          ),
          Container(
            width: 105,
            height: double.infinity,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 20),
            decoration: const BoxDecoration(
              color: KColors.sand,
              border: Border(left: BorderSide(color: KColors.brown, width: 0.8)),
            ),
            child: Text(b.takaran, style: ks(16, w: FontWeight.w700, c: KColors.brown)),
          ),
        ],
      ),
    );
  }
}

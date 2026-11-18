import 'package:flutter/material.dart';

import 'kasir_model.dart';
import 'kasir_theme.dart';
import 'kasir_widgets.dart';

class DetailTransaksiPage extends StatelessWidget {
  final Transaksi trx;
  const DetailTransaksiPage({super.key, required this.trx});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const KasirTopBar(title: 'Detail Transaksi'),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(25, 23, 25, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 43,
                            height: 43,
                            decoration: BoxDecoration(
                              color: KColors.iconBg,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Icon(Icons.assignment_outlined,
                                color: KColors.brown, size: 24),
                          ),
                          const SizedBox(width: 10),
                          Text(trx.kode, style: ks(24, w: FontWeight.w800, c: KColors.brown)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      _infoRow('Tanggal & Waktu', formatWaktu(trx.waktu)),
                      _infoRow('Kasir', trx.kasir),
                      _infoRow('Metode Pembayaran', trx.metodeBayar),
                      const SizedBox(height: 22),
                      const SectionTitle('Detail Pesanan'),
                      const SizedBox(height: 8),
                      OrderLines(items: trx.items),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                TotalBar(jumlahItem: trx.jumlahItem, total: trx.total),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(label, style: ks(11, w: FontWeight.w700, c: KColors.rust)),
          const Spacer(),
          Text(value, style: ks(11, c: KColors.inkSoft)),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import 'kasir_model.dart';
import 'kasir_theme.dart';
import 'kasir_widgets.dart';
import 'pilih_menu.dart';

class TransaksiBerhasilPage extends StatelessWidget {
  final Transaksi trx;
  const TransaksiBerhasilPage({super.key, required this.trx});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(25, 0, 25, 24),
          child: Column(
            children: [
              const Spacer(flex: 3),
              Container(
                width: 128,
                height: 128,
                decoration: const BoxDecoration(
                  color: Color(0xFFFDE7C4),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Container(
                    width: 98,
                    height: 98,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF59E2B),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 62,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 22),
              Text(
                'Transaksi Berhasil',
                style: ks(30, w: FontWeight.w800, c: KColors.rust),
              ),
              const SizedBox(height: 6),
              Text(
                'Transaksi penjualan berhasil disimpan dan stok bahan telah diperbarui.',
                textAlign: TextAlign.center,
                style: ks(13, c: KColors.brown, h: 1.4),
              ),
              const SizedBox(height: 40),
              Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 22),
                padding: const EdgeInsets.fromLTRB(26, 22, 26, 26),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
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
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              trx.kode,
                              style: ks(
                                17,
                                w: FontWeight.w800,
                                c: KColors.navyDark,
                              ),
                            ),
                            Text(
                              formatWaktu(trx.waktu),
                              style: ks(12, c: KColors.grey),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: Column(
                        children: [
                          Text('Subtotal', style: ks(12, c: KColors.grey)),
                          Text(
                            rupiah(trx.total),
                            style: ks(32, w: FontWeight.w800, c: KColors.rust),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(flex: 4),
              KButton(
                label: 'Buat Transaksi Baru',
                onPressed: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const PilihMenuPage()),
                ),
              ),
              const SizedBox(height: 12),
              KButton(
                label: 'Kembali ke Beranda',
                outlined: true,
                onPressed: () {
                  KasirStore.instance.tab.value = 0;
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

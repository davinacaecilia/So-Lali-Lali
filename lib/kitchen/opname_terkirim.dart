import 'package:flutter/material.dart';

import '../kasir/kasir_theme.dart';
import '../kasir/kasir_widgets.dart';
import 'detail_hasil_opname.dart';
import 'kitchen_model.dart';

class OpnameTerkirimPage extends StatelessWidget {
  final OpnameSesi sesi;
  const OpnameTerkirimPage({super.key, required this.sesi});

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
                    child: const Icon(Icons.check_rounded, color: Colors.white, size: 62),
                  ),
                ),
              ),
              const SizedBox(height: 22),
              Text('Hasil Opname\nDikirimkan',
                  textAlign: TextAlign.center,
                  style: ks(30, w: FontWeight.w800, c: KColors.rust, h: 1.3)),
              const SizedBox(height: 8),
              Text('Hasil Opname akan direview oleh Owner\nsebelum stok diperbaharui',
                  textAlign: TextAlign.center,
                  style: ks(13, c: KColors.brown, h: 1.4)),
              const Spacer(flex: 4),
              KButton(
                label: 'Lihat Detail Hasil Opname',
                onPressed: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => DetailHasilOpnamePage(sesi: sesi)),
                ),
              ),
              const SizedBox(height: 12),
              KButton(
                label: 'Kembali ke Beranda',
                outlined: true,
                onPressed: () {
                  KitchenStore.instance.tab.value = 0;
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

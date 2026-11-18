import 'package:flutter/material.dart';

import 'daftar_menu.dart';
import 'dashboard_kasir.dart';
import 'kasir_model.dart';
import 'kasir_widgets.dart';
import 'riwayat.dart';

/// Kerangka utama Kasir: header + 3 tab (Beranda, Menu, Riwayat) + bottom nav.
class KasirScreen extends StatelessWidget {
  const KasirScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = KasirStore.instance;
    return ValueListenableBuilder<int>(
      valueListenable: store.tab,
      builder: (context, index, _) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: Column(
            children: [
              const KasirHeader(),
              Expanded(
                child: IndexedStack(
                  index: index,
                  children: const [
                    DashboardPage(),
                    DaftarMenuPage(),
                    RiwayatPage(),
                  ],
                ),
              ),
            ],
          ),
          bottomNavigationBar: KasirBottomNav(
            index: index,
            onTap: (i) => store.tab.value = i,
          ),
        );
      },
    );
  }
}

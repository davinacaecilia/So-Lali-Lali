import 'package:flutter/material.dart';

import 'dashboard_kitchen.dart';
import 'daftar_menu.dart';
import 'kitchen_model.dart';
import 'kitchen_widgets.dart';
import 'opname.dart';
import 'stok.dart';
import 'waste.dart';

/// Kerangka utama Kitchen: header + 5 tab + bottom nav.
class KitchenScreen extends StatelessWidget {
  const KitchenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = KitchenStore.instance;
    return ValueListenableBuilder<int>(
      valueListenable: store.tab,
      builder: (context, index, _) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: Column(
            children: [
              const KitchenHeader(),
              Expanded(
                child: IndexedStack(
                  index: index,
                  children: const [
                    DashboardKitchenPage(),
                    DaftarMenuKitchenPage(),
                    StokPage(),
                    WastePage(),
                    OpnamePage(),
                  ],
                ),
              ),
            ],
          ),
          bottomNavigationBar: KitchenBottomNav(
            index: index,
            onTap: (i) => store.tab.value = i,
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';

import '../partials/bottom_nav.dart';
import '../partials/colors.dart';
import '../partials/header.dart';
import 'daftar_bahan.dart';
import 'daftar_menu.dart';
import 'filter_bahan.dart';

/// Halaman Item: header + toggle tab (Bahan / Menu) + bottom nav.
/// Isi tiap tab ada di file masing-masing:
///   - tab Bahan -> daftar_bahan.dart  (DaftarBahan)
///   - tab Menu  -> daftar_menu.dart   (belum dibuat)
class ItemPage extends StatefulWidget {
  /// Sheet filter yang dipakai tab Bahan. Bawaan: filter owner.
  final BahanFilterOpener openFilter;

  const ItemPage({super.key, this.openFilter = showFilterBahanSheet});

  @override
  State<ItemPage> createState() => _ItemPageState();
}

class _ItemPageState extends State<ItemPage> {
  static const _orange = Color(0xFF2D4068); // biru tua (tab aktif)
  static const _peach = Color(0xFFCFE2FF);  // biru muda (latar toggle)

  int _tab = 0; // 0 = Bahan, 1 = Menu
  int _navIndex = 1; // Item

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const DashboardHeader(),
          Padding(
            padding: const EdgeInsets.fromLTRB(25, 23, 25, 12),
            child: _buildTabSwitch(),
          ),
          Expanded(child: _buildTabContent()),
          OwnerBottomNav(
            currentIndex: _navIndex,
            onTap: (i) => setState(() => _navIndex = i),
          ),
        ],
      ),
    );
  }

  // ---------- Isi tab ----------
  // Widget tab dibuat ulang tiap berpindah tab, jadi pencarian & filter
  // otomatis kembali ke awal (sama seperti perilaku sebelumnya).
  Widget _buildTabContent() {
    if (_tab == 0) {
      return DaftarBahan(openFilter: widget.openFilter);
    }

    return const DaftarMenu();
    
  }

  // ---------- Toggle Bahan / Menu ----------
  Widget _buildTabSwitch() {
    return Container(
      height: 42,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: _peach,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(children: [_tabItem('Bahan', 0), _tabItem('Menu', 1)]),
    );
  }

  Widget _tabItem(String label, int index) {
    final selected = _tab == index;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => setState(() => _tab = index),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? _orange : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
              color: selected ? Colors.white : AppColors.textDark,
            ),
          ),
        ),
      ),
    );
  }
}
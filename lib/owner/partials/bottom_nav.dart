import 'package:flutter/material.dart';
import '../daftar_bahan.dart';
import '../dashboard.dart';
import 'colors.dart';

class _NavData {
  final IconData icon;
  final String label;
  const _NavData(this.icon, this.label);
}

class OwnerBottomNav extends StatelessWidget {
  final int currentIndex;

  /// Opsional: kalau diisi, dipanggil setelah navigasi bawaan.
  final ValueChanged<int>? onTap;

  const OwnerBottomNav({
    super.key,
    required this.currentIndex,
    this.onTap,
  });

  /// Pindah halaman sesuai tab. Urutan: 0 Beranda, 1 Item, 2 Supplier,
  /// 3 Laporan, 4 Riwayat.
  void _navigate(BuildContext context, int index) {
    if (index == currentIndex) return;

    final Widget page;
    switch (index) {
      case 0:
        page = const DashboardOwnerPage();
        break;
      case 1:
        page = const ItemPage();
        break;
      // TODO: case 2 Supplier, case 3 Laporan, case 4 Riwayat
      default:
        return;
    }

    // pushReplacement + tanpa animasi supaya terasa seperti ganti tab
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => page,
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  static const _items = <_NavData>[
    _NavData(Icons.home_outlined, 'Beranda'),
    _NavData(Icons.grid_view_rounded, 'Item'),
    _NavData(Icons.local_shipping_outlined, 'Supplier'),
    _NavData(Icons.assignment_outlined, 'Laporan'),
    _NavData(Icons.history_rounded, 'Riwayat'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 10, bottom: 12),
      decoration: const BoxDecoration(
        color: AppColors.headerBg,
        border: Border(top: BorderSide(color: Color(0xFFE6DCCB))),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(_items.length, (i) {
            final selected = i == currentIndex;
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                _navigate(context, i);
                onTap?.call(i);
              },
              child: SizedBox(
                width: 72,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 48,
                      height: 46,
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.navSelected
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        _items[i].icon,
                        size: 24,
                        color: i == 1 ? AppColors.brown : AppColors.brownDark,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _items[i].label,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
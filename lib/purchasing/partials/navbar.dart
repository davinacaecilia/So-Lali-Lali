import 'package:flutter/material.dart';
import '../dashboard.dart';
import '../stok/stokpage.dart';
import '../purchase/purchase_page.dart';
import '../terima/terima_page.dart';
import '../opname/opname_page.dart';
import 'colors.dart';

/// Bottom navigation.
class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int>? onTap;

  const AppBottomNav({
    super.key,
    this.currentIndex = 0,
    this.onTap,
  });

  static const List<_NavData> _items = [
    _NavData(Icons.home_outlined, 'Beranda'),
    _NavData(Icons.inventory_2, 'Stok'),
    _NavData(Icons.monetization_on_outlined, 'Purchase'),
    _NavData(Icons.volunteer_activism_outlined, 'Terima'),
    _NavData(Icons.assignment_outlined, 'Opname'),
  ];

  /// Pindah halaman saat menu ditekan.
  /// Jika FE memberi [onTap] sendiri, maka [onTap] yang dipakai.
  void _handleTap(BuildContext context, int index) {
    if (index == currentIndex) return;

    if (onTap != null) {
      onTap!(index);
      return;
    }

    Widget? page;
    if (index == 0) {
      page = const DashboardPurchasing();
    } else if (index == 1) {
      page = const StokPage();
    } else if (index == 2) {
      page = const PurchasePage();
    } else if (index == 3) {
      page = const TerimaPage();
    } else if (index == 4) {
      page = const OpnamePage();
    }

    if (page == null) return;

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => page!,
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
        left: 12,
        right: 12,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.divider, width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          for (int i = 0; i < _items.length; i++)
            _NavItem(
              data: _items[i],
              active: i == currentIndex,
              onTap: () => _handleTap(context, i),
            ),
        ],
      ),
    );
  }
}

class _NavData {
  final IconData icon;
  final String label;
  const _NavData(this.icon, this.label);
}

class _NavItem extends StatelessWidget {
  final _NavData data;
  final bool active;
  final VoidCallback onTap;

  const _NavItem({
    required this.data,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 62,
            height: 48,
            decoration: BoxDecoration(
              color: active ? AppColors.navActiveBg : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(data.icon, color: AppColors.iconBrown, size: 28),
          ),
          const SizedBox(height: 6),
          Text(
            data.label,
            style: const TextStyle(
              fontFamily: kFont,
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.brownDark,
            ),
          ),
        ],
      ),
    );
  }
}
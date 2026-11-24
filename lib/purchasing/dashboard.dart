import 'package:flutter/material.dart';

import 'partials/colors.dart';
import 'partials/navbar.dart';
import 'partials/header.dart';
import 'partials/status_badge.dart';
import 'opname/hasil_opname.dart' show HasilOpnamePage;
import 'opname/opname_page.dart';
import 'purchase/detail_po.dart' show DetailPoPage;
import 'purchase/purchase_page.dart';
import 'stok/stokpage.dart';
import 'terima/terima_page.dart';
import 'purchase/buat_po.dart';
import 'stok/riwayat_restock.dart';

// ============================ MODEL (DUMMY) ============================
enum _ItemType { box, po, opname, terima }

class _RestockItem {
  final _ItemType type;
  final String title;
  final String subtitle;
  final String time;
  final AppStatus? status;
  final String? trailingText;

  const _RestockItem({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.time,
    this.status,
    this.trailingText,
  });
}

const List<_RestockItem> _dummyItems = [
  _RestockItem(
    type: _ItemType.box,
    title: 'Request Restock',
    subtitle: 'RR-241129–002',
    time: '13:59 WIB',
    trailingText: '1 item',
  ),
  _RestockItem(
    type: _ItemType.po,
    title: 'Purchase Order',
    subtitle: 'PO-0016',
    time: '13:59 WIB',
    trailingText: '1 item',
  ),
  _RestockItem(
    type: _ItemType.opname,
    title: 'Opname Mingguan',
    subtitle: '16 Nov - 22 Nov 2026',
    time: '13:59 WIB',
    status: AppStatus.menunggu,
  ),
  _RestockItem(
    type: _ItemType.opname,
    title: 'Opname Mingguan',
    subtitle: '16 Nov - 22 Nov 2026',
    time: '13:59 WIB',
    status: AppStatus.disetujui,
  ),
  _RestockItem(
    type: _ItemType.terima,
    title: 'Terima Barang',
    subtitle: 'PO-0016',
    time: '13:59 WIB',
    trailingText: '1 item',
  ),
];

// ============================ PAGE ============================
class DashboardPurchasing extends StatelessWidget {
  const DashboardPurchasing({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const AppHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(25, 30, 25, 24),
              child: Column(
                children: const [
                  _QuickActions(),
                  SizedBox(height: 28),
                  _SummaryCards(),
                  SizedBox(height: 28),
                  _RestockCard(),
                ],
              ),
            ),
          ),
          const AppBottomNav(currentIndex: 0),
        ],
      ),
    );
  }
}

// ============================ QUICK ACTIONS ============================
class _QuickActions extends StatelessWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ActionButton(
          icon: Icons.add,
          label: 'Purchase\nOrder',
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const BuatPoPage.manual())),
        ),
        _ActionButton(
          icon: Icons.inventory_2,
          label: 'Riwayat\nRestock',
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const RiwayatRestockPage())),
        ),
        _ActionButton(
          icon: Icons.assignment_outlined,
          label: 'Opname\nHarian',
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const OpnamePage())),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
      width: 80,
      child: Column(
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.white, size: 32),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: kFont,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.brownDark,
              height: 1.25,
            ),
          ),
        ],
      ),
    ),
    );
  }
}

// ============================ SUMMARY CARDS ============================
class _SummaryCards extends StatelessWidget {
  const _SummaryCards();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const StokPage())),
            child: const _SummaryCard(
              value: '80',
              label: 'Request Restock\nbelum di PO',
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: GestureDetector(
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const PurchasePage())),
            child: const _SummaryCard(
              value: '80',
              label: 'PO menunggu\nApproval Owner',
            ),
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String value;
  final String label;

  const _SummaryCard({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 26, 12, 22),
      decoration: BoxDecoration(
        color: AppColors.cardWarnBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.cardWarnBorder, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontFamily: kFont,
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: AppColors.orange,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontFamily: kFont,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.brownDark,
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================ RESTOCK CARD ============================
class _RestockCard extends StatelessWidget {
  const _RestockCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.cardBorder, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Aktivitas Terbaru',
            style: TextStyle(
              fontFamily: kFont,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.brown,
            ),
          ),
          const SizedBox(height: 14),
          for (final item in _dummyItems) _RestockRow(item: item),
        ],
      ),
    );
  }
}

class _RestockRow extends StatelessWidget {
  final _RestockItem item;

  const _RestockRow({required this.item});

  IconData get _icon {
    switch (item.type) {
      case _ItemType.box:
        return Icons.inventory_2;
      case _ItemType.po:
        return Icons.monetization_on_outlined;
      case _ItemType.terima:
        return Icons.volunteer_activism_outlined;
      case _ItemType.opname:
        return Icons.assignment_outlined;
    }
  }

  void _open(BuildContext context) {
    final Widget page;
    switch (item.type) {
      case _ItemType.box:
        page = const RiwayatRestockPage();
        break;
      case _ItemType.po:
        page = const DetailPoPage();
        break;
      case _ItemType.opname:
        page = HasilOpnamePage(waiting: item.status == AppStatus.menunggu);
        break;
      case _ItemType.terima:
        page = const TerimaPage();
        break;
    }
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _open(context),
        child: _content(context),
      );

  Widget _content(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.iconTile,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(_icon, color: AppColors.iconBrown, size: 24),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: kFont,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.brownDark,
                    height: 1.25,
                  ),
                ),
                Text(
                  item.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: kFont,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: AppColors.subText,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (item.status != null)
                StatusBadge(status: item.status!)
              else
                Text(
                  item.trailingText!,
                  style: const TextStyle(
                    fontFamily: kFont,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.diprosesText,
                    height: 1.25,
                  ),
                ),
              const SizedBox(height: 4),
              Text(
                item.time,
                style: const TextStyle(
                  fontFamily: kFont,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: AppColors.subText,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
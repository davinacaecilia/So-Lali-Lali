import 'package:flutter/material.dart';

import 'partials/colors.dart';
import 'partials/navbar.dart';
import 'partials/header.dart';
import 'partials/status_badge.dart';

/// Dashboard Staff Purchasing - SO LALI LALI
/// Hanya tampilan (UI). Data masih dummy, logic & integrasi API dikerjakan FE.

// ============================ MODEL (DUMMY) ============================
enum _ItemType { box, waste, opname }

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
    status: AppStatus.diproses,
  ),
  _RestockItem(
    type: _ItemType.waste,
    title: 'Waste',
    subtitle: 'Susu UHT Full Cream',
    time: '',
    trailingText: '2 L',
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
    type: _ItemType.box,
    title: 'Request Restock',
    subtitle: 'RR-241129–002',
    time: '13:59 WIB',
    status: AppStatus.ditolak,
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
      children: const [
        _ActionButton(icon: Icons.add, label: 'Purchase\nOrder'),
        _ActionButton(
            icon: Icons.document_scanner_outlined, label: 'Scan\nTerima'),
        _ActionButton(icon: Icons.assignment_outlined, label: 'Opname\nHarian'),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ActionButton({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
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
              fontFamily: 'Poppins',
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

// ============================ SUMMARY CARDS ============================
class _SummaryCards extends StatelessWidget {
  const _SummaryCards();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(
          child: _SummaryCard(
            title: 'Stock Menipis',
            value: '80',
            note: 'dibawah minimum',
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: _SummaryCard(
            title: 'Hampir Expired',
            value: '80',
            note: 'dalam 7 hari',
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final String note;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.note,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.cardWarnBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardWarnBorder, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppColors.brownDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: AppColors.orange,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            note,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.red,
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
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Request Restock Terbaru',
            style: TextStyle(
              fontFamily: 'Poppins',
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
      case _ItemType.waste:
        return Icons.delete_outline_rounded;
      case _ItemType.opname:
        return Icons.assignment_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
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
                    fontFamily: 'Poppins',
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
                    fontFamily: 'Poppins',
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
          if (item.trailingText != null)
            Text(
              item.trailingText!,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                StatusBadge(status: item.status!),
                const SizedBox(height: 4),
                Text(
                  item.time,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
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
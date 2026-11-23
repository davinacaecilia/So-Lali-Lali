import 'package:flutter/material.dart';

import '../partials/colors.dart';
import '../partials/header.dart';
import '../partials/navbar.dart';
import 'filter_bahan.dart';
import 'informasi_bahan.dart';
import 'riwayat_restock.dart';

/// Halaman Stok - Staff Purchasing
/// Hanya tampilan (UI). Data masih dummy, logic & integrasi API dikerjakan FE.

// ============================ MODEL (DUMMY) ============================
class _StokItem {
  final IconData icon;
  final String name;
  final String category;
  final String qty;
  final StokStatus status;

  const _StokItem({
    required this.icon,
    required this.name,
    required this.category,
    required this.qty,
    required this.status,
  });
}

const List<_StokItem> _dummyStok = [
  _StokItem(
    icon: Icons.bakery_dining_outlined,
    name: 'Tepung Terigu',
    category: 'Bahan Kering',
    qty: '16 kg',
    status: StokStatus.aman,
  ),
  _StokItem(
    icon: Icons.grain,
    name: 'Gula Pasir',
    category: 'Bahan Kering',
    qty: '12,5 kg',
    status: StokStatus.aman,
  ),
  _StokItem(
    icon: Icons.local_drink_outlined,
    name: 'Susu UHT Full Cream',
    category: 'Minuman',
    qty: '6 liter',
    status: StokStatus.menipis,
  ),
  _StokItem(
    icon: Icons.coffee_outlined,
    name: 'Biji Kopi Arabika',
    category: 'Minuman',
    qty: '8 kg',
    status: StokStatus.aman,
  ),
  _StokItem(
    icon: Icons.layers_outlined,
    name: 'Mentega',
    category: 'Susu dan Olahan',
    qty: '2 kg',
    status: StokStatus.menipis,
  ),
  _StokItem(
    icon: Icons.kebab_dining,
    name: 'Fillet Ayam',
    category: 'Protein',
    qty: '0 kg',
    status: StokStatus.habis,
  ),
];

// ============================ PAGE ============================
class StokPage extends StatelessWidget {
  const StokPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const AppHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(top: 24, bottom: 16),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: Column(
                      children: [
                        _SearchRow(
                          onFilterTap: () => showFilterBahan(context),
                        ),
                        const SizedBox(height: 10),
                        const _HistoryBanner(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  for (final item in _dummyStok) _StokRow(item: item),
                ],
              ),
            ),
          ),
          const AppBottomNav(currentIndex: 1),
        ],
      ),
    );
  }
}

// ============================ BANNER RIWAYAT ============================
class _HistoryBanner extends StatelessWidget {
  const _HistoryBanner();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary,
      borderRadius: BorderRadius.circular(4),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const RiwayatRestockPage()),
          );
        },
        borderRadius: BorderRadius.circular(4),
        child: Container(
          width: double.infinity,
          height: 51,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: const Row(
            children: [
              Expanded(
                child: Text(
                  'Lihat Riwayat Request Restock',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: Colors.white, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================ ITEM STOK ============================
class _StokRow extends StatelessWidget {
  final _StokItem item;

  const _StokRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final Color qtyColor;
    switch (item.status) {
      case StokStatus.menipis:
        qtyColor = AppColors.menipisChipText;
        break;
      case StokStatus.habis:
        qtyColor = AppColors.habisChipText;
        break;
      default:
        qtyColor = AppColors.brownDark;
    }

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => InformasiBahanPage(
              name: item.name,
              category: item.category,
              status: item.status,
            ),
          ),
        );
      },
      child: Padding(
      padding: const EdgeInsets.fromLTRB(33, 11, 41, 11),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Icon tile
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.tilePeach,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(item.icon, color: AppColors.iconBrown, size: 32),
          ),
          const SizedBox(width: 14),
          // Nama + kategori
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.brownDark,
                    height: 1.3,
                  ),
                ),
                Text(
                  item.category,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: AppColors.subText,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          // Status + qty
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _StokChip(status: item.status),
              const SizedBox(height: 4),
              Text(
                item.qty,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: qtyColor,
                ),
              ),
            ],
          ),
        ],
      ),
      ),
    );
  }
}

class _StokChip extends StatelessWidget {
  final StokStatus status;

  const _StokChip({required this.status});

  @override
  Widget build(BuildContext context) {
    late final String label;
    late final IconData icon;
    late final Color bg;
    late final Color fg;

    switch (status) {
      case StokStatus.menipis:
        label = 'Menipis';
        icon = Icons.warning_amber_rounded;
        bg = AppColors.menipisChipBg;
        fg = AppColors.menipisChipText;
        break;
      case StokStatus.habis:
        label = 'Habis';
        icon = Icons.cancel_outlined;
        bg = AppColors.habisChipBg;
        fg = AppColors.habisChipText;
        break;
      case StokStatus.aman:
      case StokStatus.semua:
        label = 'Aman';
        icon = Icons.check_circle_outline_rounded;
        bg = AppColors.amanChipBg;
        fg = AppColors.amanChipText;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: fg, size: 14),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================ SEARCH + FILTER ============================

class _SearchRow extends StatelessWidget {
  final VoidCallback onFilterTap;

  const _SearchRow({required this.onFilterTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.cardWarnBg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.cardWarnBorder, width: 1),
            ),
            child: Row(
              children: [
                const Icon(Icons.search, color: AppColors.iconBrown, size: 22),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      color: AppColors.brownDark,
                    ),
                    decoration: InputDecoration(
                      isDense: true,
                      border: InputBorder.none,
                      hintText: 'Cari nama menu',
                      hintStyle: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        color: AppColors.subText.withOpacity(0.7),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        InkWell(
          onTap: onFilterTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.cardWarnBg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.cardWarnBorder, width: 1),
            ),
            child: const Icon(Icons.tune_rounded,
                color: AppColors.iconBrown, size: 22),
          ),
        ),
      ],
    );
  }
}
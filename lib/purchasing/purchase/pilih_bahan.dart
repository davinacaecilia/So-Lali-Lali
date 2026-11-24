import 'package:flutter/material.dart';

import '../partials/colors.dart';

/// Popup "Pilih Bahan" (bottom sheet) - dipakai di halaman Buat PO manual
/// (tombol "Tambah Bahan"). Hanya tampilan, data masih dummy.
///
/// Bahan yang dipilih dikembalikan lewat Navigator.pop (null jika ditutup).
/// Bahan yang sudah ada di daftar ([alreadyAdded]) tampil abu-abu & tidak bisa dipilih.

// ============================ MODEL (DUMMY) ============================
enum StokLevel { habis, menipis, aman }

class BahanOption {
  final String name;
  final String category;
  final String unit;
  final double stock;
  final StokLevel level;

  const BahanOption({
    required this.name,
    required this.category,
    required this.unit,
    required this.stock,
    required this.level,
  });

  String get stockText =>
      '${stock % 1 == 0 ? stock.toInt() : stock} $unit';
}

// TODO FE: ganti dengan data bahan dari API
const List<BahanOption> _dummyBahan = [
  BahanOption(
    name: 'Biji Kopi Arabika',
    category: 'Minuman & Biji Kopi',
    unit: 'kg',
    stock: 12,
    level: StokLevel.aman,
  ),
  BahanOption(
    name: 'Susu UHT Full Cream',
    category: 'Susu & Olahan',
    unit: 'liter',
    stock: 0,
    level: StokLevel.habis,
  ),
  BahanOption(
    name: 'Gula Pasir',
    category: 'Bahan Kering',
    unit: 'kg',
    stock: 3,
    level: StokLevel.menipis,
  ),
  BahanOption(
    name: 'Sirup Vanila',
    category: 'Minuman & Biji Kopi',
    unit: 'liter',
    stock: 16,
    level: StokLevel.aman,
  ),
  BahanOption(
    name: 'Tepung Terigu',
    category: 'Bahan Kering',
    unit: 'kg',
    stock: 20,
    level: StokLevel.aman,
  ),
  BahanOption(
    name: 'Dada Ayam Fillet',
    category: 'Protein & Daging',
    unit: 'kg',
    stock: 2,
    level: StokLevel.menipis,
  ),
  BahanOption(
    name: 'Bubuk Cokelat',
    category: 'Bahan Kering',
    unit: 'kg',
    stock: 9,
    level: StokLevel.aman,
  ),
];

/// Tampilkan popup. Mengembalikan [BahanOption] yang dipilih.
Future<BahanOption?> showPilihBahan(
  BuildContext context, {
  Set<String> alreadyAdded = const {},
}) {
  return showModalBottomSheet<BahanOption>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
      child: FractionallySizedBox(
        heightFactor: 0.8,
        child: _PilihBahanSheet(alreadyAdded: alreadyAdded),
      ),
    ),
  );
}

// ============================ SHEET ============================
class _PilihBahanSheet extends StatefulWidget {
  final Set<String> alreadyAdded;

  const _PilihBahanSheet({required this.alreadyAdded});

  @override
  State<_PilihBahanSheet> createState() => _PilihBahanSheetState();
}

class _PilihBahanSheetState extends State<_PilihBahanSheet> {
  String _query = '';

  List<BahanOption> get _filtered {
    final list = _dummyBahan
        .where((b) => b.name.toLowerCase().contains(_query.toLowerCase()))
        .toList();
    // Habis & menipis di atas supaya mudah dipilih untuk restock.
    list.sort((a, b) => a.level.index.compareTo(b.level.index));
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final items = _filtered;

    return SafeArea(
      child: Column(
        children: [
          const SizedBox(height: 10),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.sheetHandle,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(23, 14, 23, 0),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Pilih Bahan',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.brownDark,
                    ),
                  ),
                ),
                InkWell(
                  onTap: () => Navigator.pop(context),
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: AppColors.tilePeach,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(Icons.close,
                        size: 18, color: AppColors.sectionTitle),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(23, 14, 23, 8),
            child: _SearchBox(onChanged: (v) => setState(() => _query = v)),
          ),
          Expanded(
            child: items.isEmpty
                ? const Center(
                    child: Text(
                      'Bahan tidak ditemukan',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        color: AppColors.subText,
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(23, 6, 23, 16),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (_, i) {
                      final b = items[i];
                      final bool added = widget.alreadyAdded.contains(b.name);
                      return _BahanRow(
                        bahan: b,
                        disabled: added,
                        onTap: added ? null : () => Navigator.pop(context, b),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _SearchBox extends StatelessWidget {
  final ValueChanged<String> onChanged;

  const _SearchBox({required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
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
              onChanged: onChanged,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                color: AppColors.brownDark,
              ),
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: 'Cari nama bahan',
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
    );
  }
}

// ============================ BARIS BAHAN ============================
class _BahanRow extends StatelessWidget {
  final BahanOption bahan;
  final bool disabled;
  final VoidCallback? onTap;

  const _BahanRow({
    required this.bahan,
    required this.disabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Opacity(
        opacity: disabled ? 0.55 : 1,
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.iconTile,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.inventory_2_outlined,
                  size: 20, color: AppColors.iconBrown),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bahan.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.brownDark,
                    ),
                  ),
                  Text(
                    '${bahan.category.split(' & ').first} · ${bahan.unit}',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11,
                      color: AppColors.subText,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                disabled
                    ? const _Chip(
                        label: 'Sudah dalam daftar',
                        bg: Color(0xFFEDE6DA),
                        fg: AppColors.subText,
                      )
                    : _levelChip(bahan.level),
                if (!disabled) ...[
                  const SizedBox(height: 2),
                  Text(
                    bahan.stockText,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.brownDark,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _levelChip(StokLevel l) {
    switch (l) {
      case StokLevel.habis:
        return const _Chip(
          label: 'Habis',
          bg: AppColors.habisChipBg,
          fg: AppColors.habisChipText,
          icon: Icons.cancel_outlined,
        );
      case StokLevel.menipis:
        return const _Chip(
          label: 'Menipis',
          bg: AppColors.menipisChipBg,
          fg: AppColors.menipisChipText,
          icon: Icons.warning_amber_rounded,
        );
      case StokLevel.aman:
        return const _Chip(
          label: 'Aman',
          bg: AppColors.amanChipBg,
          fg: AppColors.amanChipText,
          icon: Icons.check_circle_outline,
        );
    }
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color bg;
  final Color fg;
  final IconData? icon;

  const _Chip({
    required this.label,
    required this.bg,
    required this.fg,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 11, color: fg),
            const SizedBox(width: 3),
          ],
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}
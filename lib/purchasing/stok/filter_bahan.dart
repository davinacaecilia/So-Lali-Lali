import 'package:flutter/material.dart';

import '../partials/colors.dart';

/// Filter Bahan (bottom sheet) - halaman Stok Purchasing.
/// Hanya tampilan. Hasil filter dikembalikan lewat [StokFilter] saat
/// tombol "Terapkan Filter" ditekan (null jika sheet ditutup tanpa apply).

// ============================ MODEL ============================
enum StokStatus { semua, aman, menipis, habis }

enum StokSort { nama, stokTersedikit, cepatKedaluwarsa }

class StokFilter {
  final int categoryIndex;
  final StokStatus status;
  final StokSort sort;

  const StokFilter({
    this.categoryIndex = 0,
    this.status = StokStatus.semua,
    this.sort = StokSort.nama,
  });
}

class _Category {
  final String name;
  final int count;
  const _Category(this.name, this.count);
}

// Data dummy kategori (FE menggantinya dengan data dari API)
const List<_Category> _categories = [
  _Category('Semua Kategori', 14),
  _Category('Bahan Kering', 5),
  _Category('Minuman & Biji Kopi', 4),
  _Category('Susu & Olahan', 3),
  _Category('Protein & Daging', 2),
  _Category('Bumbu & Rempah', 2),
];

/// Tampilkan bottom sheet filter.
Future<StokFilter?> showFilterBahan(
  BuildContext context, {
  StokFilter initial = const StokFilter(),
}) {
  return showModalBottomSheet<StokFilter>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => FilterBahanSheet(initial: initial),
  );
}

// ============================ SHEET ============================
class FilterBahanSheet extends StatefulWidget {
  final StokFilter initial;

  const FilterBahanSheet({super.key, this.initial = const StokFilter()});

  @override
  State<FilterBahanSheet> createState() => _FilterBahanSheetState();
}

class _FilterBahanSheetState extends State<FilterBahanSheet> {
  late int _category;
  late StokStatus _status;
  late StokSort _sort;

  @override
  void initState() {
    super.initState();
    _category = widget.initial.categoryIndex;
    _status = widget.initial.status;
    _sort = widget.initial.sort;
  }

  void _reset() {
    setState(() {
      _category = 0;
      _status = StokStatus.semua;
      _sort = StokSort.nama;
    });
  }

  void _apply() {
    Navigator.pop(
      context,
      StokFilter(categoryIndex: _category, status: _status, sort: _sort),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SheetHeader(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 23),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  // ---------- Kategori ----------
                  for (int i = 0; i < _categories.length; i++)
                    _CategoryTile(
                      category: _categories[i],
                      selected: i == _category,
                      onTap: () => setState(() => _category = i),
                    ),
                  const SizedBox(height: 14),
                  // ---------- Status ----------
                  const _SectionTitle('Status Ketersediaan Stok'),
                  const SizedBox(height: 8),
                  _StatusChips(
                    selected: _status,
                    onChanged: (v) => setState(() => _status = v),
                  ),
                  const SizedBox(height: 18),
                  // ---------- Urutkan ----------
                  const _SectionTitle('Urutkan Berdasarkan'),
                  const SizedBox(height: 8),
                  _SortChips(
                    selected: _sort,
                    onChanged: (v) => setState(() => _sort = v),
                  ),
                  const SizedBox(height: 24),
                  // ---------- Tombol ----------
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: _SheetButton(
                          label: 'Reset',
                          icon: Icons.refresh_rounded,
                          background: AppColors.filterItemBg,
                          foreground: AppColors.primary,
                          onTap: _reset,
                        ),
                      ),
                      const SizedBox(width: 13),
                      Expanded(
                        flex: 3,
                        child: _SheetButton(
                          label: 'Terapkan Filter',
                          icon: Icons.check_rounded,
                          background: AppColors.orange,
                          foreground: Colors.white,
                          onTap: _apply,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================ HEADER SHEET ============================
class _SheetHeader extends StatelessWidget {
  const _SheetHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 10),
        Center(
          child: Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.sheetHandle,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(23, 20, 23, 10),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: AppColors.cardWarnBorder, width: 1),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Filter Bahan',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppColors.brownDark,
                        height: 1.2,
                      ),
                    ),
                    Text(
                      'Pilih kategori dan status stok bahan dapur',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: AppColors.subText,
                      ),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: () => Navigator.pop(context),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.filterItemBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    color: AppColors.brownDark,
                    size: 22,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ============================ KATEGORI ============================
class _CategoryTile extends StatelessWidget {
  final _Category category;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryTile({
    required this.category,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.filterItemSelectedBg
                : AppColors.filterItemBg,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            children: [
              _RadioDot(selected: selected),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  category.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                    color: AppColors.brownDark,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.pillBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${category.count} menu',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.brownDark,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RadioDot extends StatelessWidget {
  final bool selected;

  const _RadioDot({required this.selected});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected ? AppColors.orange : AppColors.pillBg,
      ),
      alignment: Alignment.center,
      child: selected
          ? Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.brownDark,
              ),
            )
          : null,
    );
  }
}

// ============================ SECTION TITLE ============================
class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: 'Poppins',
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.sectionTitle,
      ),
    );
  }
}

// ============================ STATUS CHIPS ============================
class _StatusChips extends StatelessWidget {
  final StokStatus selected;
  final ValueChanged<StokStatus> onChanged;

  const _StatusChips({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    Widget chip({
      required StokStatus value,
      required String label,
      required Color bg,
      required Color fg,
      Color? dot,
    }) {
      final bool active = selected == value;
      return Expanded(
        child: GestureDetector(
          onTap: () => onChanged(value),
          child: Container(
            height: 32,
            decoration: BoxDecoration(
              color: active && value == StokStatus.semua ? AppColors.orange : bg,
              borderRadius: BorderRadius.circular(4),
              border: active && value != StokStatus.semua
                  ? Border.all(color: fg, width: 1.2)
                  : null,
            ),
            alignment: Alignment.center,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (dot != null) ...[
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 6),
                ],
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: active && value == StokStatus.semua
                        ? Colors.white
                        : fg,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        chip(
          value: StokStatus.semua,
          label: 'Semua',
          bg: AppColors.filterItemBg,
          fg: AppColors.brownDark,
        ),
        const SizedBox(width: 3),
        chip(
          value: StokStatus.aman,
          label: 'Aman',
          bg: AppColors.amanChipBg,
          fg: AppColors.amanChipText,
          dot: AppColors.amanChipText,
        ),
        const SizedBox(width: 3),
        chip(
          value: StokStatus.menipis,
          label: 'Menipis',
          bg: AppColors.filterItemSelectedBg,
          fg: AppColors.sectionTitle,
          dot: AppColors.menipisChipText,
        ),
        const SizedBox(width: 3),
        chip(
          value: StokStatus.habis,
          label: 'Habis',
          bg: AppColors.habisChipBg,
          fg: AppColors.habisChipText,
          dot: AppColors.habisChipText,
        ),
      ],
    );
  }
}

// ============================ SORT CHIPS ============================
class _SortChips extends StatelessWidget {
  final StokSort selected;
  final ValueChanged<StokSort> onChanged;

  const _SortChips({required this.selected, required this.onChanged});

  static const List<MapEntry<StokSort, String>> _options = [
    MapEntry(StokSort.nama, 'Nama (A-Z)'),
    MapEntry(StokSort.stokTersedikit, 'Stok Tersedikit'),
    MapEntry(StokSort.cepatKedaluwarsa, 'Paling Cepat Kedaluwarsa'),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _options.length,
        separatorBuilder: (_, __) => const SizedBox(width: 3),
        itemBuilder: (_, i) {
          final option = _options[i];
          final bool active = option.key == selected;
          return GestureDetector(
            onTap: () => onChanged(option.key),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: active ? AppColors.orange : AppColors.filterItemBg,
                borderRadius: BorderRadius.circular(4),
              ),
              alignment: Alignment.center,
              child: Text(
                option.value,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: active ? Colors.white : AppColors.brownDark,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ============================ BUTTON ============================
class _SheetButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color background;
  final Color foreground;
  final VoidCallback onTap;

  const _SheetButton({
    required this.label,
    required this.icon,
    required this.background,
    required this.foreground,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(6),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: foreground, size: 20),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: foreground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
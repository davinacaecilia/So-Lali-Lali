import 'package:flutter/material.dart';

import 'colors.dart';

// =====================================================
// MODEL HASIL FILTER
// =====================================================
/// Status stok bahan (dipakai juga oleh daftar_bahan_page.dart).
enum StockStatus { aman, menipis, habis }

enum BahanSort { nama, stokTersedikit, kedaluwarsa }

class FilterBahan {
  static const semuaKategori = 'Semua Kategori';

  final String category;
  final StockStatus? status; // null = Semua
  final BahanSort sort;

  const FilterBahan({
    this.category = semuaKategori,
    this.status,
    this.sort = BahanSort.nama,
  });

  bool get isDefault =>
      category == semuaKategori &&
      status == null &&
      sort == BahanSort.nama;
}

/// Membuka sheet filter. Mengembalikan [FilterBahan] jika user menekan
/// "Terapkan Filter", atau null jika sheet ditutup tanpa menerapkan.
///
/// [counts] = jumlah item per kategori (key = label kategori, termasuk
/// "Semua Kategori"). Urutan key menentukan urutan baris di sheet.
Future<FilterBahan?> showFilterBahanSheet(
  BuildContext context, {
  required FilterBahan current,
  required Map<String, int> counts,
}) {
  return showModalBottomSheet<FilterBahan>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => FilterBahanSheet(initial: current, counts: counts),
  );
}

// =====================================================
// SHEET
// =====================================================
class FilterBahanSheet extends StatefulWidget {
  final FilterBahan initial;
  final Map<String, int> counts;

  const FilterBahanSheet({
    super.key,
    required this.initial,
    required this.counts,
  });

  @override
  State<FilterBahanSheet> createState() => _FilterBahanSheetState();
}

class _FilterBahanSheetState extends State<FilterBahanSheet> {
  // Warna khusus sheet ini (diambil dari desain)
  static const _orange = Color(0xFFE59E2C);
  static const _peach = Color(0xFFFFEAD8);
  static const _rowBg = Color(0xFFFFEEE2);
  static const _rowBgSelected = Color(0xFFFFE3CC);
  static const _radioOff = Color(0xFFFADCC2);
  static const _handle = Color(0xFFD9C3AD);
  static const _sectionTitle = Color(0xFF9A3B12);
  static const _subtitle = Color(0xFF6E6358);
  static const _resetText = Color(0xFF4A5A7A);

  late String _category;
  late StockStatus? _status;
  late BahanSort _sort;

  @override
  void initState() {
    super.initState();
    _category = widget.initial.category;
    _status = widget.initial.status;
    _sort = widget.initial.sort;
  }

  void _reset() {
    setState(() {
      _category = FilterBahan.semuaKategori;
      _status = null;
      _sort = BahanSort.nama;
    });
  }

  void _apply() {
    Navigator.pop(
      context,
      FilterBahan(category: _category, status: _status, sort: _sort),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 10),
        // Handle
        Container(
          width: 26,
          height: 4,
          decoration: BoxDecoration(
            color: _handle,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        _buildHeader(),
        const Divider(height: 1, thickness: 1, color: _peach),
        Flexible(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...widget.counts.entries.map(_categoryRow),
                const SizedBox(height: 14),
                _sectionLabel('Status Food Cost'),
                const SizedBox(height: 8),
                _buildStatusChips(),
                const SizedBox(height: 18),
                _sectionLabel('Urutkan Berdasarkan'),
                const SizedBox(height: 8),
                _buildSortChips(),
              ],
            ),
          ),
        ),
        _buildActions(),
      ],
    );
  }

  // ---------- Header ----------
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 14, 24, 10),
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
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                    height: 1.2,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Pilih kategori dan status stok bahan dapur',
                  style: TextStyle(fontSize: 12, color: _subtitle),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _peach,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.close,
                  size: 20, color: AppColors.brownDark),
            ),
          ),
        ],
      ),
    );
  }

  // ---------- Baris kategori ----------
  Widget _categoryRow(MapEntry<String, int> e) {
    final selected = _category == e.key;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => setState(() => _category = e.key),
      child: Container(
        height: 46,
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: selected ? _rowBgSelected : _rowBg,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            // Radio
            Container(
              width: 22,
              height: 22,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? _orange : _radioOff,
              ),
              child: selected
                  ? Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF5A3A10),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                e.key,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                  color: AppColors.textDark,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 2),
              decoration: BoxDecoration(
                color: _radioOff,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${e.value} menu',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.brownDark,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: _sectionTitle,
      ),
    );
  }

  // ---------- Chip status ----------
  Widget _buildStatusChips() {
    final chips = <Widget>[
      _statusChip(
        label: 'Semua',
        value: null,
        bg: _peach,
        fg: AppColors.textDark,
      ),
      _statusChip(
        label: 'Aman',
        value: StockStatus.aman,
        bg: const Color(0xFFE6F4E8),
        fg: AppColors.green,
        dot: AppColors.green,
      ),
      _statusChip(
        label: 'Menipis',
        value: StockStatus.menipis,
        bg: const Color(0xFFFFE3D6),
        fg: const Color(0xFF8A3B12),
        dot: const Color(0xFFA0541A),
      ),
      _statusChip(
        label: 'Habis',
        value: StockStatus.habis,
        bg: const Color(0xFFFFE3E6),
        fg: AppColors.red,
        dot: AppColors.red,
      ),
    ];

    return Row(
      children: [
        for (int i = 0; i < chips.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          chips[i],
        ],
      ],
    );
  }

  Widget _statusChip({
    required String label,
    required StockStatus? value,
    required Color bg,
    required Color fg,
    Color? dot,
  }) {
    final selected = _status == value;
    final isAll = value == null;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _status = value),
        child: Container(
          height: 34,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isAll && selected ? _orange : bg,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: selected && !isAll ? fg : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (dot != null) ...[
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: dot),
                ),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isAll && selected ? Colors.white : fg,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------- Chip urutan ----------
  Widget _buildSortChips() {
    const options = <BahanSort, String>{
      BahanSort.nama: 'Nama (A-Z)',
      BahanSort.stokTersedikit: 'Stok Tersedikit',
      BahanSort.kedaluwarsa: 'Paling Cepat Kedaluwarsa',
    };

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      child: Row(
        children: options.entries.map((e) {
          final selected = _sort == e.key;
          return GestureDetector(
            onTap: () => setState(() => _sort = e.key),
            child: Container(
              height: 34,
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? _orange : _peach,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                e.value,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: selected ? Colors.white : AppColors.textDark,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ---------- Tombol Reset + Terapkan ----------
  Widget _buildActions() {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
        child: Row(
          children: [
            Expanded(
              flex: 10,
              child: SizedBox(
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _reset,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _peach,
                    foregroundColor: _resetText,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: const Icon(Icons.restart_alt_rounded, size: 18),
                  label: const Text(
                    'Reset',
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 13,
              child: SizedBox(
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _apply,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _orange,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: const Icon(Icons.check, size: 18),
                  label: const Text(
                    'Terapkan Filter',
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
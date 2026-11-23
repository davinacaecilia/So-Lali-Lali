import 'package:flutter/material.dart';

import '../partials/colors.dart';

// =====================================================
// MODEL FILTER
// =====================================================

/// Status food cost. Batasnya mengikuti desain:
///   Aman    : <= 30%
///   Waspada : 30 - 35%
///   Kritis  : > 35%
enum FoodCostStatus { aman, waspada, kritis }

const double kFoodCostAman = 30;
const double kFoodCostWaspada = 35;

FoodCostStatus foodCostStatusOf(double foodCost) {
  if (foodCost <= kFoodCostAman) return FoodCostStatus.aman;
  if (foodCost <= kFoodCostWaspada) return FoodCostStatus.waspada;
  return FoodCostStatus.kritis;
}

/// Label kategori di sheet filter -> nilai `category` pada MenuModel.
/// (Urutannya sama dengan urutan di sheet.)
const Map<String, String> kKategoriMenuFilter = {
  'Makanan Utama': 'Makanan Utama',
  'Minuman Kopi': 'Minuman Kopi',
  'Minuman Non-Kopi': 'Minuman Non-Kopi',
  'Camilan & Penutup': 'Camilan & Penutup',
};

class FilterMenu {
  static const semuaKategori = 'Semua Kategori';

  final String category;

  /// null = "Semua" status food cost
  final FoodCostStatus? foodCost;

  const FilterMenu({this.category = semuaKategori, this.foodCost});

  bool get isDefault => category == semuaKategori && foodCost == null;
}

// =====================================================
// FUNGSI PEMBUKA SHEET
// =====================================================

/// Membuka sheet "Filter Menu". Mengembalikan pilihan user,
/// atau null jika ditutup tanpa menerapkan.
Future<FilterMenu?> showFilterMenuSheet(
  BuildContext context, {
  required FilterMenu current,
  required Map<String, int> counts,
}) {
  return showModalBottomSheet<FilterMenu>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => _FilterMenuSheet(current: current, counts: counts),
  );
}

// =====================================================
// SHEET
// =====================================================
class _FilterMenuSheet extends StatefulWidget {
  final FilterMenu current;
  final Map<String, int> counts;

  const _FilterMenuSheet({required this.current, required this.counts});

  @override
  State<_FilterMenuSheet> createState() => _FilterMenuSheetState();
}

class _FilterMenuSheetState extends State<_FilterMenuSheet> {
  // Warna khusus sheet ini (diambil dari desain).
  // Pindahkan ke AppColors jika sudah ada padanannya.
  static const _handle = Color(0xFFD9C9B8);
  static const _rowBg = Color(0xFFFEEBDC);
  static const _rowSelectedBg = Color(0xFFFDE3CE);
  static const _radioOff = Color(0xFFF8D8BD);
  static const _countBg = Color(0xFFFDDDC4);
  static const _sectionTitle = Color(0xFF8A3B12);
  static const _resetText = Color(0xFF334A7A);

  late String _category;
  FoodCostStatus? _foodCost;

  @override
  void initState() {
    super.initState();
    _category = widget.current.category;
    _foodCost = widget.current.foodCost;
  }

  void _reset() {
    setState(() {
      _category = FilterMenu.semuaKategori;
      _foodCost = null;
    });
  }

  void _apply() {
    Navigator.pop(context, FilterMenu(category: _category, foodCost: _foodCost));
  }

  @override
  Widget build(BuildContext context) {
    final labels = [FilterMenu.semuaKategori, ...kKategoriMenuFilter.keys];

    return SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(context),
          Container(height: 1, color: AppColors.cardBorder),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(top: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ----- Kategori -----
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: Column(
                      children: [
                        for (final label in labels) ...[
                          _buildCategoryRow(label),
                          const SizedBox(height: 4),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // ----- Status Food Cost -----
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          'Status Food Cost',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: _sectionTitle,
                          ),
                        ),
                        Text(
                          'Target: ≤30%',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.subtitle,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: Row(
                      children: [
                        _buildChip('Semua', null),
                        const SizedBox(width: 8),
                        _buildChip('Aman (≤30%)', FoodCostStatus.aman),
                        const SizedBox(width: 8),
                        _buildChip('Waspada (30–35%)', FoodCostStatus.waspada),
                        const SizedBox(width: 8),
                        _buildChip('Kritis (>35%)', FoodCostStatus.kritis),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ----- Tombol -----
          Padding(
            padding: const EdgeInsets.fromLTRB(25, 22, 25, 24),
            child: Row(
              children: [
                Expanded(
                  flex: 7,
                  child: SizedBox(
                    height: 54,
                    child: ElevatedButton.icon(
                      onPressed: _reset,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _rowBg,
                        foregroundColor: _resetText,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      icon: const Icon(Icons.restart_alt_rounded, size: 18),
                      label: const Text(
                        'Reset',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 10,
                  child: SizedBox(
                    height: 54,
                    child: ElevatedButton.icon(
                      onPressed: _apply,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.orangeAccent,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      icon: const Icon(Icons.check, size: 20),
                      label: const Text(
                        'Terapkan Filter',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================= HEADER =================
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(25, 10, 25, 12),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: _handle,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Filter Menu',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Pilih kategori untuk menyaring daftar menu',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.subtitle,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Material(
                color: _rowBg,
                borderRadius: BorderRadius.circular(10),
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () => Navigator.pop(context),
                  child: const SizedBox(
                    width: 38,
                    height: 38,
                    child: Icon(
                      Icons.close,
                      size: 20,
                      color: AppColors.textDark,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ================= BARIS KATEGORI =================
  Widget _buildCategoryRow(String label) {
    final selected = _category == label;
    final count = widget.counts[label] ?? 0;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => setState(() => _category = label),
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: selected ? _rowSelectedBg : _rowBg,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            // radio
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? AppColors.orangeAccent : _radioOff,
              ),
              child: selected
                  ? Center(
                      child: Container(
                        width: 9,
                        height: 9,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.textDark,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                  color: AppColors.textDark,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: _countBg,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$count menu',
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= CHIP STATUS FOOD COST =================
  Widget _buildChip(String label, FoodCostStatus? value) {
    final selected = _foodCost == value;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => setState(() => _foodCost = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? AppColors.orangeAccent : _rowBg,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? Colors.white : AppColors.textDark,
          ),
        ),
      ),
    );
  }
}
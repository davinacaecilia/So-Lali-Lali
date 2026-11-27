import 'package:flutter/material.dart';

import '../../constants/menu_options.dart';
import '../partials/colors.dart';

// =====================================================
// KOMPATIBILITAS (food cost sudah dihapus dari aplikasi)
// Dibiarkan karena halaman edit mungkin masih memakainya.
// Hapus setelah halaman edit dibersihkan.
// =====================================================
enum FoodCostStatus { aman, waspada, kritis }

const double kFoodCostAman = 30;
const double kFoodCostWaspada = 35;

FoodCostStatus foodCostStatusOf(double foodCost) {
  if (foodCost <= kFoodCostAman) return FoodCostStatus.aman;
  if (foodCost <= kFoodCostWaspada) return FoodCostStatus.waspada;
  return FoodCostStatus.kritis;
}

/// (Kompatibilitas) label kategori -> label kategori, diturunkan dari
/// [kMenuCategories]. Dipertahankan kalau ada halaman lain yang memakainya.
final Map<String, String> kKategoriMenuFilter = {
  for (final c in kMenuCategories) c.label: c.label,
};

// =====================================================
// MODEL FILTER
// =====================================================
class FilterMenu {
  /// Nilai khusus untuk "tanpa filter kategori".
  static const semuaKategori = 'semua';

  /// Kunci kategori (mis. "minuman_kopi"), atau [semuaKategori].
  final String category;

  const FilterMenu({this.category = semuaKategori});

  bool get isDefault => category == semuaKategori;
}

// =====================================================
// FUNGSI PEMBUKA SHEET
// =====================================================

/// Membuka sheet "Filter Menu". Mengembalikan pilihan user,
/// atau null jika ditutup tanpa menerapkan.
///
/// [counts] = jumlah menu per kategori (key = KUNCI kategori, termasuk
/// [FilterMenu.semuaKategori]). Urutan key menentukan urutan baris.
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
  static const _handle = Color(0xFFD9C9B8);
  static const _rowBg = Color(0xFFFEEBDC);
  static const _rowSelectedBg = Color(0xFFFDE3CE);
  static const _radioOff = Color(0xFFF8D8BD);
  static const _countBg = Color(0xFFFDDDC4);
  static const _resetText = Color(0xFF334A7A);

  late String _category;

  @override
  void initState() {
    super.initState();
    _category = widget.current.category;
  }

  /// Label tampilan untuk kunci kategori.
  String _categoryLabel(String key) => key == FilterMenu.semuaKategori
      ? 'Semua Kategori'
      : menuCategoryByKey(key).label;

  void _reset() => setState(() => _category = FilterMenu.semuaKategori);

  void _apply() => Navigator.pop(context, FilterMenu(category: _category));

  @override
  Widget build(BuildContext context) {
    final keys = widget.counts.keys.toList();

    return SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(context),
          Container(height: 1, color: AppColors.cardBorder),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(25, 12, 25, 0),
              child: Column(
                children: [
                  for (final key in keys) ...[
                    _buildCategoryRow(key),
                    const SizedBox(height: 4),
                  ],
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
  Widget _buildCategoryRow(String key) {
    final selected = _category == key;
    final count = widget.counts[key] ?? 0;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => setState(() => _category = key),
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
                _categoryLabel(key),
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
}
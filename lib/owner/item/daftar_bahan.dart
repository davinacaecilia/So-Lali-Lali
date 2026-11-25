import 'dart:async';

import 'package:flutter/material.dart';

import '../../constants/ingredient_options.dart';
import '../../models/ingredient.dart';
import '../../services/ingredient_service.dart';
import '../partials/colors.dart';
import 'filter_bahan.dart';
import 'informasi_bahan.dart';
import 'tambah_bahan.dart';

// =====================================================
// MODEL TAMPILAN
// =====================================================
class BahanItem {
  final String id;
  final String name;
  final String category; // label untuk tampilan
  final String categoryKey; // kunci untuk filter
  final String quantity; // sudah termasuk satuan, mis. "16 kg"
  final StockStatus status;
  final IconData icon;
  final DateTime? expiry; // kedaluwarsa terdekat (untuk urutan)

  const BahanItem({
    this.id = '',
    required this.name,
    required this.category,
    this.categoryKey = '',
    required this.quantity,
    required this.status,
    required this.icon,
    this.expiry,
  });

  factory BahanItem.fromIngredient(Ingredient i) => BahanItem(
    id: i.id,
    name: i.name,
    category: i.category.label,
    categoryKey: i.categoryKey,
    quantity: formatQty(i.totalStock, i.unit),
    status: _statusOf(i),
    icon: _iconFor(i.categoryKey),
    expiry: i.nearestExpiry,
  );

  /// Angka dari "12,5 kg" -> 12.5 (dipakai untuk urut "Stok Tersedikit")
  double get stock {
    final m = RegExp(r'[\d.,]+').firstMatch(quantity);
    if (m == null) return 0;
    return double.tryParse(m.group(0)!.replaceAll(',', '.')) ?? 0;
  }
}

StockStatus _statusOf(Ingredient i) {
  if (i.totalStock <= 0) return StockStatus.habis;
  if (i.totalStock < i.minStock) return StockStatus.menipis;
  return StockStatus.aman;
}

IconData _iconFor(String categoryKey) {
  switch (categoryKey) {
    case 'bahan_kering':
      return Icons.grain;
    case 'susu_olahan':
      return Icons.local_drink_outlined;
    case 'daging_unggas':
      return Icons.kebab_dining;
    case 'seafood':
      return Icons.set_meal_outlined;
    case 'telur':
      return Icons.egg_outlined;
    case 'sayur_buah':
      return Icons.eco_outlined;
    case 'bumbu_rempah':
      return Icons.spa_outlined;
    case 'minyak_lemak':
      return Icons.water_drop_outlined;
    case 'minuman_sirup':
      return Icons.coffee_outlined;
    case 'bahan_beku':
      return Icons.ac_unit;
    default:
      return Icons.category_outlined;
  }
}

/// Label kategori di filter -> kunci kategori pada BahanItem.
/// (Urutannya sama dengan urutan di sheet filter.)
const Map<String, String> kKategoriFilter = {
  'Bahan Kering': 'bahan_kering',
  'Minuman & Biji Kopi': 'minuman_sirup',
  'Susu & Olahan': 'susu_olahan',
  'Protein & Daging': 'daging_unggas',
  'Bumbu & Rempah': 'bumbu_rempah',
};

/// Fungsi yang membuka sheet filter dan mengembalikan pilihan user
/// (null jika ditutup tanpa menerapkan). Setiap "versi" halaman cukup
/// memberi fungsi yang berbeda; tampilan halamannya tetap sama.
typedef BahanFilterOpener =
Future<FilterBahan?> Function(
    BuildContext context, {
    required FilterBahan current,
    required Map<String, int> counts,
    });

// =====================================================
// KONTEN TAB "BAHAN"
// (dipakai di dalam ItemPage; tidak punya header / bottom nav sendiri)
// =====================================================
class DaftarBahan extends StatefulWidget {
  /// Sheet filter yang dipakai. Bawaan: filter owner.
  final BahanFilterOpener openFilter;

  const DaftarBahan({super.key, this.openFilter = showFilterBahanSheet});

  @override
  State<DaftarBahan> createState() => _DaftarBahanState();
}

class _DaftarBahanState extends State<DaftarBahan> {
  // Warna khusus halaman ini (diambil dari desain)
  static const _orange = AppColors.orangeAccent;
  static const _peach = AppColors.peach;
  static const _field = AppColors.fieldBg;
  static const _fieldBorder = AppColors.fieldBorder;
  static const _hint = AppColors.fieldHint;
  static const _iconMuted = AppColors.mutedIcon;
  static const _subtitle = AppColors.subtitle;
  static const _cube = AppColors.cube;

  // ------------------------------------------------------------
  // DATA dari Firestore (realtime)
  // ------------------------------------------------------------
  List<BahanItem> _bahan = [];
  bool _loading = true;
  String? _error;
  StreamSubscription<List<Ingredient>>? _sub;

  final TextEditingController _searchCtrl = TextEditingController();
  String _query = '';
  FilterBahan _filter = const FilterBahan();

  @override
  void initState() {
    super.initState();
    _sub = IngredientService.instance.watchAll().listen(
          (list) {
        if (!mounted) return;
        setState(() {
          _bahan = list.map(BahanItem.fromIngredient).toList();
          _loading = false;
          _error = null;
        });
      },
      onError: (e) {
        debugPrint('watchAll error: $e');
        if (!mounted) return;
        setState(() {
          _loading = false;
          _error = 'Gagal memuat data bahan.';
        });
      },
    );
  }

  @override
  void dispose() {
    _sub?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  List<BahanItem> get _visible {
    final q = _query.trim().toLowerCase();
    final match = kKategoriFilter[_filter.category];

    final list = _bahan.where((e) {
      if (q.isNotEmpty && !e.name.toLowerCase().contains(q)) return false;
      if (_filter.category != FilterBahan.semuaKategori &&
          e.categoryKey != match) {
        return false;
      }
      if (_filter.status != null && e.status != _filter.status) return false;
      return true;
    }).toList();

    switch (_filter.sort) {
      case BahanSort.nama:
        list.sort(
              (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
        );
        break;
      case BahanSort.stokTersedikit:
        list.sort((a, b) => a.stock.compareTo(b.stock));
        break;
      case BahanSort.kedaluwarsa:
        list.sort((a, b) {
          if (a.expiry == null && b.expiry == null) return 0;
          if (a.expiry == null) return 1;
          if (b.expiry == null) return -1;
          return a.expiry!.compareTo(b.expiry!);
        });
        break;
    }
    return list;
  }

  /// Jumlah item per kategori untuk ditampilkan di sheet filter.
  Map<String, int> _categoryCounts() {
    final counts = <String, int>{FilterBahan.semuaKategori: _bahan.length};
    kKategoriFilter.forEach((label, match) {
      counts[label] = _bahan.where((e) => e.categoryKey == match).length;
    });
    return counts;
  }

  Future<void> _openFilter() async {
    final result = await widget.openFilter(
      context,
      current: _filter,
      counts: _categoryCounts(),
    );
    if (result != null) setState(() => _filter = result);
  }

  void _goTambah() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const TambahBahanBaruPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = _visible;

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(25, 0, 25, 100),
          child: Column(
            children: [
              _buildSearchRow(),
              const SizedBox(height: 24),
              _buildBody(items),
            ],
          ),
        ),
        // Tombol tambah (hanya muncul jika ada data)
        if (_bahan.isNotEmpty)
          Positioned(right: 24, bottom: 20, child: _buildAddFab()),
      ],
    );
  }

  // ---------- Pilih tampilan: memuat / error / kosong / tidak ketemu / daftar ----------
  Widget _buildBody(List<BahanItem> items) {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.only(top: 60),
        child: CircularProgressIndicator(color: _orange),
      );
    }

    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.only(top: 32),
        child: _buildEmptyState(
          icon: Icons.error_outline,
          title: 'Gagal memuat',
          subtitle: _error!,
        ),
      );
    }

    // 1) Data memang belum ada
    if (_bahan.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 32),
        child: _buildEmptyState(
          icon: Icons.inventory_2_outlined,
          title: 'Belum ada bahan baku',
          subtitle: 'Tambahkan bahan pertama Anda untuk mulai memantau stok.',
          buttonLabel: 'Tambahkan Bahan',
        ),
      );
    }

    // 2) Ada data tetapi hasil pencarian kosong
    if (items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 32),
        child: _buildEmptyState(
          icon: Icons.search_off_rounded,
          title: 'Tidak ditemukan',
          subtitle: 'Tidak ada bahan yang sesuai dengan pencarian atau filter.',
        ),
      );
    }

    // 3) Tampilkan daftar
    return Column(children: items.map((e) => _BahanTile(item: e)).toList());
  }

  // ---------- Search + filter ----------
  Widget _buildSearchRow() {
    OutlineInputBorder border() => OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: _fieldBorder),
    );

    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 44,
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _query = v),
              style: const TextStyle(fontSize: 14, color: AppColors.textDark),
              decoration: InputDecoration(
                hintText: 'Cari nama bahan',
                hintStyle: const TextStyle(fontSize: 14, color: _hint),
                prefixIcon: const Icon(
                  Icons.search,
                  size: 20,
                  color: _iconMuted,
                ),
                filled: true,
                fillColor: _field,
                contentPadding: EdgeInsets.zero,
                enabledBorder: border(),
                focusedBorder: border(),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: _openFilter,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _filter.isDefault ? _field : _orange,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: _filter.isDefault ? _fieldBorder : _orange,
              ),
            ),
            child: Icon(
              Icons.tune_rounded,
              size: 22,
              color: _filter.isDefault ? _iconMuted : Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  // ---------- Tombol tambah (+) ----------
  Widget _buildAddFab() {
    return Material(
      color: _orange,
      elevation: 4,
      shadowColor: AppColors.strongShadow,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: _goTambah,
        child: const SizedBox(
          width: 54,
          height: 54,
          child: Icon(Icons.add, color: Colors.white, size: 26),
        ),
      ),
    );
  }

  // ---------- Empty state ----------
  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    String? buttonLabel,
  }) {
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: _peach,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, size: 32, color: _cube),
        ),
        const SizedBox(height: 18),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          width: 270,
          child: Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13.5,
              height: 1.45,
              color: _subtitle,
            ),
          ),
        ),
        if (buttonLabel != null) ...[
          const SizedBox(height: 24),
          SizedBox(
            width: 220,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: _goTambah,
              style: ElevatedButton.styleFrom(
                backgroundColor: _orange,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: const Icon(Icons.add, size: 20),
              label: Text(
                buttonLabel,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// =====================================================
// BARIS BAHAN
// =====================================================
class _BahanTile extends StatelessWidget {
  final BahanItem item;
  const _BahanTile({required this.item});

  static const _peach = AppColors.peach;
  static const _subtitle = AppColors.lightSubtitle;
  static const _warnText = AppColors.warningStatusText;

  @override
  Widget build(BuildContext context) {
    final style = _statusStyle(item.status);

    return Padding(
      padding: const EdgeInsets.only(bottom: 25),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => InformasiBahanPage(
                name: item.name,
                category: item.category,
                status: item.status,
                icon: item.icon,
                unit: item.quantity.split(' ').skip(1).join(' '),
              ),
            ),
          );
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Ikon bahan
            Container(
              width: 63,
              height: 63,
              decoration: BoxDecoration(
                color: _peach,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(item.icon, size: 28, color: AppColors.brown),
            ),
            const SizedBox(width: 15),
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
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                      height: 1.25,
                    ),
                  ),
                  Text(
                    item.category,
                    style: const TextStyle(
                      fontSize: 12,
                      color: _subtitle,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Badge status + jumlah
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: style.bg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(style.icon, size: 13, color: style.fg),
                      const SizedBox(width: 4),
                      Text(
                        style.label,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: style.fg,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  item.quantity,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: style.qtyColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  _StatusStyle _statusStyle(StockStatus s) {
    switch (s) {
      case StockStatus.aman:
        return const _StatusStyle(
          label: 'Aman',
          icon: Icons.check_circle_outline,
          bg: AppColors.safeBg,
          fg: AppColors.green,
          qtyColor: AppColors.textDark,
        );
      case StockStatus.menipis:
        return const _StatusStyle(
          label: 'Menipis',
          icon: Icons.warning_amber_rounded,
          bg: AppColors.warningStatusBg,
          fg: _warnText,
          qtyColor: _warnText,
        );
      case StockStatus.habis:
        return const _StatusStyle(
          label: 'Habis',
          icon: Icons.cancel_outlined,
          bg: AppColors.exhaustedStatusBg,
          fg: AppColors.red,
          qtyColor: AppColors.red,
        );
    }
  }
}

class _StatusStyle {
  final String label;
  final IconData icon;
  final Color bg;
  final Color fg;
  final Color qtyColor;

  const _StatusStyle({
    required this.label,
    required this.icon,
    required this.bg,
    required this.fg,
    required this.qtyColor,
  });
}
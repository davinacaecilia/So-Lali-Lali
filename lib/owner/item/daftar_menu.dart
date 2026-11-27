import 'dart:async';

import 'package:flutter/material.dart';

import '../../constants/ingredient_options.dart' show cloudinaryResize;
import '../../constants/menu_options.dart';
import '../../models/menu_data.dart';
import '../../services/menu_service.dart';
import '../partials/colors.dart';
import 'filter_menu.dart';
import 'informasi_menu.dart';
import 'tambah_menu.dart';

// =====================================================
// MODEL TAMPILAN
// =====================================================
class RecipeItem {
  final String? ingredientId;
  final String name;
  final double qty;
  final String unit;
  final double unitPrice; // kompatibilitas: tidak dipakai lagi

  const RecipeItem({
    this.ingredientId,
    required this.name,
    required this.qty,
    this.unit = 'g',
    this.unitPrice = 0,
  });
}

class MenuModel {
  final String docId; // id dokumen Firestore (untuk simpan/ubah)
  final String id; // kode tampilan, mis. "MKU-001"
  final String name;
  final String category; // label untuk tampilan
  final String categoryKey; // kunci untuk filter
  final int price;
  final double? foodCost; // kompatibilitas: food cost dihapus, tidak dipakai
  final List<RecipeItem> recipe;
  final String? photoUrl; // link foto (Cloudinary)
  final String? imageAsset;
  final IconData icon;

  const MenuModel({
    this.docId = '',
    this.id = '-',
    required this.name,
    required this.category,
    this.categoryKey = '',
    required this.price,
    this.foodCost,
    this.recipe = const [],
    this.photoUrl,
    this.imageAsset,
    this.icon = Icons.restaurant_menu,
  });

  factory MenuModel.fromData(MenuData d) => MenuModel(
    docId: d.id,
    id: d.code,
    name: d.name,
    category: menuCategoryByKey(d.categoryKey).label,
    categoryKey: d.categoryKey,
    price: d.price,
    recipe: d.recipe
        .map(
          (r) => RecipeItem(
        ingredientId: r.ingredientId,
        name: r.name,
        qty: r.qty,
        unit: r.unit,
      ),
    )
        .toList(),
    photoUrl: d.photoUrl,
    icon: _menuIconFor(d.categoryKey),
  );

  bool get hasRecipe => recipe.isNotEmpty;

  /// Kompatibilitas: food cost dihapus, selalu 0.
  int get materialCost => 0;
}

IconData _menuIconFor(String categoryKey) {
  switch (categoryKey) {
    case 'makanan_utama':
      return Icons.lunch_dining_outlined;
    case 'camilan_penutup':
      return Icons.icecream_outlined;
    case 'roti_kue':
      return Icons.bakery_dining_outlined;
    case 'minuman_kopi':
      return Icons.coffee_outlined;
    case 'minuman_non_kopi':
      return Icons.emoji_food_beverage_outlined;
    case 'paket_combo':
      return Icons.takeout_dining_outlined;
    case 'tambahan_topping':
      return Icons.add_circle_outline;
    default:
      return Icons.restaurant_menu;
  }
}

// =====================================================
// KONTEN TAB "MENU"
// (dipakai di dalam ItemPage; tidak punya header / bottom nav sendiri)
// =====================================================
class DaftarMenu extends StatefulWidget {
  const DaftarMenu({super.key});

  @override
  State<DaftarMenu> createState() => _DaftarMenuState();
}

class _DaftarMenuState extends State<DaftarMenu> {
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
  List<MenuModel> _menu = [];
  bool _loading = true;
  String? _error;
  StreamSubscription<List<MenuData>>? _sub;

  final TextEditingController _searchCtrl = TextEditingController();
  String _query = '';
  FilterMenu _filter = const FilterMenu();

  @override
  void initState() {
    super.initState();
    _sub = MenuService.instance.watchAll().listen(
          (list) {
        if (!mounted) return;
        setState(() {
          _menu = list.map(MenuModel.fromData).toList();
          _loading = false;
          _error = null;
        });
      },
      onError: (e) {
        debugPrint('menu watchAll error: $e');
        if (!mounted) return;
        setState(() {
          _loading = false;
          _error = 'Gagal memuat data menu.';
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

  List<MenuModel> get _visible {
    final q = _query.trim().toLowerCase();

    return _menu.where((e) {
      if (q.isNotEmpty && !e.name.toLowerCase().contains(q)) return false;
      if (_filter.category != FilterMenu.semuaKategori &&
          e.categoryKey != _filter.category) {
        return false;
      }
      return true;
    }).toList();
  }

  /// Jumlah menu per kategori untuk sheet filter (key = kunci kategori).
  /// Hanya kategori yang punya menu (atau sedang dipilih) yang ditampilkan.
  Map<String, int> _categoryCounts() {
    final counts = <String, int>{FilterMenu.semuaKategori: _menu.length};
    for (final c in kMenuCategories) {
      final n = _menu.where((e) => e.categoryKey == c.key).length;
      if (n > 0 || _filter.category == c.key) counts[c.key] = n;
    }
    return counts;
  }

  Future<void> _openFilter() async {
    final result = await showFilterMenuSheet(
      context,
      current: _filter,
      counts: _categoryCounts(),
    );
    if (result != null) setState(() => _filter = result);
  }

  void _goTambah() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const TambahMenuBaruPage()),
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
        if (_menu.isNotEmpty)
          Positioned(right: 24, bottom: 20, child: _buildAddFab()),
      ],
    );
  }

  // ---------- Pilih tampilan: memuat / error / kosong / tidak ketemu / daftar ----------
  Widget _buildBody(List<MenuModel> items) {
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

    if (_menu.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 32),
        child: _buildEmptyState(
          icon: Icons.restaurant_menu,
          title: 'Belum ada menu',
          subtitle: 'Tambahkan menu pertama Anda untuk mulai berjualan.',
          buttonLabel: 'Tambahkan Menu',
        ),
      );
    }

    if (items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 32),
        child: _buildEmptyState(
          icon: Icons.search_off_rounded,
          title: 'Tidak ditemukan',
          subtitle: 'Tidak ada menu yang sesuai dengan pencarian atau filter.',
        ),
      );
    }

    return Column(
      children: items
          .map(
            (e) => _MenuTile(
          item: e,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => InformasiMenuPage(menu: e),
              ),
            );
          },
        ),
      )
          .toList(),
    );
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
                hintText: 'Cari nama menu',
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
// BARIS MENU
// =====================================================
class _MenuTile extends StatelessWidget {
  final MenuModel item;
  final VoidCallback? onTap;

  const _MenuTile({required this.item, this.onTap});

  static const _peach = AppColors.peach;
  static const _subtitle = AppColors.lightSubtitle;

  /// 28000 -> "Rp 28.000"
  static String _fmtRupiah(int v) {
    final s = v.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return 'Rp $buf';
  }

  /// Foto menu; kalau tidak ada / gagal dimuat, tampilkan ikon kategori.
  Widget _buildThumb() {
    final fallback = Container(
      color: _peach,
      child: Icon(item.icon, size: 28, color: AppColors.brown),
    );

    final url = item.photoUrl;
    if (url != null && url.isNotEmpty) {
      return Image.network(
        cloudinaryResize(url, width: 160, height: 160),
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) =>
        progress == null ? child : fallback,
        errorBuilder: (_, __, ___) => fallback,
      );
    }
    if (item.imageAsset != null) {
      return Image.asset(
        item.imageAsset!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => fallback,
      );
    }
    return fallback;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 25),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Foto menu
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(width: 63, height: 63, child: _buildThumb()),
            ),
            const SizedBox(width: 15),
            // Nama + kategori
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    maxLines: 2,
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
            // Harga + info resep
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _fmtRupiah(item.price),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 6),
                _buildRecipeInfo(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecipeInfo() {
    if (item.hasRecipe) {
      return Text(
        '${item.recipe.length} bahan',
        style: const TextStyle(fontSize: 11.5, color: _subtitle),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.chipBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.warning_amber_rounded,
            size: 13,
            color: AppColors.brownDark,
          ),
          SizedBox(width: 4),
          Text(
            'Belum ada resep',
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: AppColors.brownDark,
            ),
          ),
        ],
      ),
    );
  }
}
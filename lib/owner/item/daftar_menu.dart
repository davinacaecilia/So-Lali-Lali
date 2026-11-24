import 'package:flutter/material.dart';

import '../partials/colors.dart';
import 'filter_menu.dart';
import 'tambah_menu.dart';
import 'informasi_menu.dart';

// =====================================================
// MODEL + DATA DUMMY  (nanti diganti data dari API)
// =====================================================
class RecipeItem {
  final String name;
  final double qty;
  final String unit; 
  final double unitPrice;

  const RecipeItem({
    required this.name,
    required this.qty,
    this.unit = 'g',
    this.unitPrice = 0,
  });
}

class MenuModel {
  final String id;
  final String name;
  final String category;
  final int price;
  final double? foodCost; // persen; null = belum ada resep
  final List<RecipeItem> recipe;
  final String? imageAsset;
  final IconData icon;

  const MenuModel({
    this.id = '-',
    required this.name,
    required this.category,
    required this.price,
    this.foodCost,
    this.recipe = const [],
    this.imageAsset,
    this.icon = Icons.restaurant_menu,
  });

  bool get hasRecipe => foodCost != null;

  /// Biaya bahan (Rp) dihitung dari harga jual x food cost.
  int get materialCost => foodCost == null ? 0 : (price * foodCost! / 100).round();
}

const List<MenuModel> dummyMenu = [
  MenuModel(
    name: 'Nasi Goreng Spesial',
    category: 'Makanan Utama',
    price: 28000,
    foodCost: 34,
  ),
  MenuModel(
    name: 'Kopi Susu Gula Aren',
    category: 'Minuman Kopi',
    price: 28000,
    foodCost: 34,
  ),
  MenuModel(
    name: 'Americano',
    category: 'Minuman Kopi',
    price: 18000,
    foodCost: null,
  ),
  MenuModel(
    name: 'Matcha Latte',
    category: 'Minuman Non-Kopi',
    price: 26000,
    foodCost: 38,
  ),
  MenuModel(
    name: 'Kentang Goreng',
    category: 'Camilan & Penutup',
    price: 15000,
    foodCost: 22,
  ),
  MenuModel(
    name: 'Ayam Geprek',
    category: 'Makanan Utama',
    price: 25000,
    foodCost: 30,
  ),
];

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
  // DATA. (dummyMenu)
  // ------------------------------------------------------------
  final List<MenuModel> _menu = dummyMenu;

  final TextEditingController _searchCtrl = TextEditingController();
  String _query = '';
  FilterMenu _filter = const FilterMenu();

  List<MenuModel> get _visible {
    final q = _query.trim().toLowerCase();
    final match = kKategoriMenuFilter[_filter.category];

    return _menu.where((e) {
      // pencarian nama
      if (q.isNotEmpty && !e.name.toLowerCase().contains(q)) return false;

      // kategori
      if (_filter.category != FilterMenu.semuaKategori &&
          e.category != match) {
        return false;
      }

      // status food cost (menu tanpa resep tidak punya status)
      if (_filter.foodCost != null) {
        final fc = e.foodCost;
        if (fc == null) return false;
        if (foodCostStatusOf(fc) != _filter.foodCost) return false;
      }

      return true;
    }).toList();
  }

  /// Jumlah menu per kategori untuk ditampilkan di sheet filter.
  Map<String, int> _categoryCounts() {
    final counts = <String, int>{FilterMenu.semuaKategori: _menu.length};
    kKategoriMenuFilter.forEach((label, match) {
      counts[label] = _menu.where((e) => e.category == match).length;
    });
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
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
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

  // ---------- Pilih tampilan: kosong / tidak ketemu / daftar ----------
  Widget _buildBody(List<MenuModel> items) {
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
      MaterialPageRoute(builder: (_) => InformasiMenuPage(menu: e)),
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

  /// 34 -> "34", 33.5 -> "33,5"
  static String _fmtPct(double v) {
    final s = v == v.roundToDouble() ? v.toInt().toString() : v.toString();
    return s.replaceAll('.', ',');
  }

  @override
  Widget build(BuildContext context) {
    final fallback = Container(
      color: _peach,
      child: Icon(item.icon, size: 28, color: AppColors.brown),
    );

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
              child: SizedBox(
                width: 63,
                height: 63,
                child: item.imageAsset != null
                    ? Image.asset(
                        item.imageAsset!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => fallback,
                      )
                    : fallback,
              ),
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
            // Harga + badge
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
                _buildBadge(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge() {
    final Color bg;
    final Color fg;
    final String label;
    IconData? icon;

    final fc = item.foodCost;
    if (fc == null) {
      bg = AppColors.chipBg;
      fg = AppColors.brownDark;
      label = 'Belum ada resep';
      icon = Icons.warning_amber_rounded;
    } else {
      label = 'Food cost ${_fmtPct(fc)}%';
      switch (foodCostStatusOf(fc)) {
        case FoodCostStatus.aman:
          bg = AppColors.safeBg;
          fg = AppColors.green;
          break;
        case FoodCostStatus.waspada:
          bg = AppColors.warningStatusBg;
          fg = AppColors.warningStatusText;
          break;
        case FoodCostStatus.kritis:
          bg = AppColors.exhaustedStatusBg;
          fg = AppColors.red;
          break;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: fg),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}
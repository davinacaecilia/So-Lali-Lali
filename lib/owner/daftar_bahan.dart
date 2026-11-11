import 'package:flutter/material.dart';

import 'partials/bottom_nav.dart';
import 'partials/colors.dart';
import 'partials/filter_bahan.dart';
import 'partials/header.dart';

// =====================================================
// MODEL + DATA DUMMY
// (nanti diganti data dari backend/API)
// =====================================================
class BahanItem {
  final String name;
  final String category;
  final String quantity; // sudah termasuk satuan, mis. "16 kg"
  final StockStatus status;
  final IconData icon;
  final DateTime? expiry; // tanggal kedaluwarsa (untuk urutan)

  const BahanItem({
    required this.name,
    required this.category,
    required this.quantity,
    required this.status,
    required this.icon,
    this.expiry,
  });

  /// Angka dari "12,5 kg" -> 12.5 (dipakai untuk urut "Stok Tersedikit")
  double get stock {
    final m = RegExp(r'[\d.,]+').firstMatch(quantity);
    if (m == null) return 0;
    return double.tryParse(m.group(0)!.replaceAll(',', '.')) ?? 0;
  }
}

/// Label kategori di filter -> nilai `category` pada BahanItem.
/// (Urutannya sama dengan urutan di sheet filter.)
const Map<String, String> kKategoriFilter = {
  'Bahan Kering': 'Bahan Kering',
  'Minuman & Biji Kopi': 'Minuman',
  'Susu & Olahan': 'Susu dan Olahan',
  'Protein & Daging': 'Protein',
  'Bumbu & Rempah': 'Bumbu & Rempah',
};

final List<BahanItem> dummyBahan = [
  BahanItem(
    name: 'Tepung Terigu',
    category: 'Bahan Kering',
    quantity: '16 kg',
    status: StockStatus.aman,
    icon: Icons.bakery_dining_outlined,
    expiry: DateTime(2027, 3, 10),
  ),
  BahanItem(
    name: 'Gula Pasir',
    category: 'Bahan Kering',
    quantity: '12,5 kg',
    status: StockStatus.aman,
    icon: Icons.grain,
    expiry: DateTime(2027, 6, 1),
  ),
  BahanItem(
    name: 'Susu UHT Full Cream',
    category: 'Minuman',
    quantity: '6 liter',
    status: StockStatus.menipis,
    icon: Icons.local_drink_outlined,
    expiry: DateTime(2026, 11, 20),
  ),
  BahanItem(
    name: 'Biji Kopi Arabika',
    category: 'Minuman',
    quantity: '8 kg',
    status: StockStatus.aman,
    icon: Icons.coffee_outlined,
    expiry: DateTime(2027, 2, 15),
  ),
  BahanItem(
    name: 'Mentega',
    category: 'Susu dan Olahan',
    quantity: '2 kg',
    status: StockStatus.menipis,
    icon: Icons.layers_outlined,
    expiry: DateTime(2026, 12, 5),
  ),
  BahanItem(
    name: 'Fillet Ayam',
    category: 'Protein',
    quantity: '0 kg',
    status: StockStatus.habis,
    icon: Icons.kebab_dining,
    expiry: DateTime(2026, 11, 14),
  ),
];

// =====================================================
// HALAMAN
// =====================================================

/// Fungsi yang membuka sheet filter dan mengembalikan pilihan user
/// (null jika ditutup tanpa menerapkan). Setiap "versi" halaman cukup
/// memberi fungsi yang berbeda; tampilan halamannya tetap sama.
typedef BahanFilterOpener = Future<FilterBahan?> Function(
  BuildContext context, {
  required FilterBahan current,
  required Map<String, int> counts,
});

/// Halaman daftar bahan (tab Bahan / Menu).
/// Satu halaman untuk semua versi; yang berbeda hanya [openFilter].
/// Otomatis menampilkan empty state jika data kosong,
/// dan daftar bahan jika data ada.
class ItemPage extends StatefulWidget {
  /// Sheet filter yang dipakai. Bawaan: filter owner.
  final BahanFilterOpener openFilter;

  const ItemPage({
    super.key,
    this.openFilter = showFilterBahanSheet,
  });

  @override
  State<ItemPage> createState() => _ItemPageState();
}

class _ItemPageState extends State<ItemPage> {
  // Warna khusus halaman ini (diambil dari desain)
  static const _orange = Color(0xFFE59E2C);
  static const _peach = Color(0xFFFFEAD8);
  static const _field = Color(0xFFFFF7F0);
  static const _fieldBorder = Color(0xFFF7E9DC);
  static const _hint = Color(0xFFC9B8A8);
  static const _iconMuted = Color(0xFF9C8B7A);
  static const _subtitle = Color(0xFF6E6358);
  static const _cube = Color(0xFF5A4636);

  // ------------------------------------------------------------
  // DATA. Untuk mencoba tampilan KOSONG, ganti dummyBahan dengan []
  // ------------------------------------------------------------
  final List<BahanItem> _bahan = dummyBahan;
  final List<BahanItem> _menu = const []; // tab Menu belum ada desainnya

  final TextEditingController _searchCtrl = TextEditingController();
  String _query = '';
  int _tab = 0; // 0 = Bahan, 1 = Menu
  int _navIndex = 1; // Item
  FilterBahan _filter = const FilterBahan();

  List<BahanItem> get _source => _tab == 0 ? _bahan : _menu;

  List<BahanItem> get _visible {
    final q = _query.trim().toLowerCase();
    final match = kKategoriFilter[_filter.category];

    final list = _source.where((e) {
      if (q.isNotEmpty && !e.name.toLowerCase().contains(q)) return false;
      if (_filter.category != FilterBahan.semuaKategori &&
          e.category != match) {
        return false;
      }
      if (_filter.status != null && e.status != _filter.status) return false;
      return true;
    }).toList();

    switch (_filter.sort) {
      case BahanSort.nama:
        list.sort(
            (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
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
    final counts = <String, int>{FilterBahan.semuaKategori: _source.length};
    kKategoriFilter.forEach((label, match) {
      counts[label] = _source.where((e) => e.category == match).length;
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

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _changeTab(int index) {
    setState(() {
      _tab = index;
      _query = '';
      _searchCtrl.clear();
      _filter = const FilterBahan();
    });
  }

  @override
  Widget build(BuildContext context) {
    final items = _visible;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const DashboardHeader(),
          Expanded(
            child: Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(25, 23, 25, 100),
                  child: Column(
                    children: [
                      _buildTabSwitch(),
                      const SizedBox(height: 12),
                      _buildSearchRow(),
                      const SizedBox(height: 24),
                      _buildBody(items),
                    ],
                  ),
                ),
                // Tombol tambah (hanya muncul jika ada data)
                if (_source.isNotEmpty)
                  Positioned(
                    right: 24,
                    bottom: 20,
                    child: _buildAddFab(),
                  ),
              ],
            ),
          ),
          OwnerBottomNav(
            currentIndex: _navIndex,
            onTap: (i) => setState(() => _navIndex = i),
          ),
        ],
      ),
    );
  }

  // ---------- Pilih tampilan: kosong / tidak ketemu / daftar ----------
  Widget _buildBody(List<BahanItem> items) {
    final label = _tab == 0 ? 'bahan' : 'menu';

    // 1) Data memang belum ada
    if (_source.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 32),
        child: _buildEmptyState(
          icon: Icons.inventory_2_outlined,
          title: _tab == 0 ? 'Belum ada bahan baku' : 'Belum ada menu',
          subtitle: _tab == 0
              ? 'Tambahkan bahan pertama Anda untuk mulai memantau stok.'
              : 'Tambahkan menu pertama Anda untuk mulai berjualan.',
          buttonLabel: _tab == 0 ? 'Tambahkan Bahan' : 'Tambahkan Menu',
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
          subtitle: 'Tidak ada $label yang sesuai dengan pencarian atau filter.',
        ),
      );
    }

    // 3) Tampilkan daftar
    return Column(
      children: items.map((e) => _BahanTile(item: e)).toList(),
    );
  }

  // ---------- Toggle Bahan / Menu ----------
  Widget _buildTabSwitch() {
    return Container(
      height: 42,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: _peach,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _tabItem('Bahan', 0),
          _tabItem('Menu', 1),
        ],
      ),
    );
  }

  Widget _tabItem(String label, int index) {
    final selected = _tab == index;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _changeTab(index),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? _orange : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
        ),
      ),
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
                hintText: _tab == 0 ? 'Cari nama bahan' : 'Cari nama menu',
                hintStyle: const TextStyle(fontSize: 14, color: _hint),
                prefixIcon:
                    const Icon(Icons.search, size: 20, color: _iconMuted),
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
      shadowColor: const Color(0x55000000),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () {
          // TODO: navigasi ke form tambah bahan
        },
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
                fontSize: 13.5, height: 1.45, color: _subtitle),
          ),
        ),
        if (buttonLabel != null) ...[
          const SizedBox(height: 24),
          SizedBox(
            width: 220,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () {
                // TODO: navigasi ke form tambah
              },
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
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
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

  static const _peach = Color(0xFFFFEAD8);
  static const _subtitle = Color(0xFF8A7F74);
  static const _warnText = Color(0xFF8A5A12);

  @override
  Widget build(BuildContext context) {
    final style = _statusStyle(item.status);

    return Padding(
      padding: const EdgeInsets.only(bottom: 25),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
    );
  }

  _StatusStyle _statusStyle(StockStatus s) {
    switch (s) {
      case StockStatus.aman:
        return const _StatusStyle(
          label: 'Aman',
          icon: Icons.check_circle_outline,
          bg: Color(0xFFE3F3E6),
          fg: AppColors.green,
          qtyColor: AppColors.textDark,
        );
      case StockStatus.menipis:
        return const _StatusStyle(
          label: 'Menipis',
          icon: Icons.warning_amber_rounded,
          bg: Color(0xFFFFF0C2),
          fg: _warnText,
          qtyColor: _warnText,
        );
      case StockStatus.habis:
        return const _StatusStyle(
          label: 'Habis',
          icon: Icons.cancel_outlined,
          bg: Color(0xFFFFE3E6),
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
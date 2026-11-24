import 'package:flutter/material.dart';

import 'daftar_menu.dart';
import 'edit_detail_menu.dart';
import 'edit_resep_menu.dart';

// =====================================================
// HALAMAN INFORMASI MENU
// Dibuka dari DaftarMenu ketika sebuah menu di-klik.
// Menerima update dari EditDetailMenuPage & EditResepMenuPage.
// =====================================================
class InformasiMenuPage extends StatefulWidget {
  final MenuModel menu;

  const InformasiMenuPage({super.key, required this.menu});

  @override
  State<InformasiMenuPage> createState() => _InformasiMenuPageState();
}

class _InformasiMenuPageState extends State<InformasiMenuPage> {
  // State data menu saat ini. Akan diperbarui jika ada kembalian dari halaman edit.
  late MenuModel menu = widget.menu;

  // ---------- Warna (disesuaikan dengan desain) ----------
  static const _headerBg = Color(0xFFFBF7EE);
  static const _navy = Color(0xFF2D3E6B);
  static const _textDark = Color(0xFF1E1408);
  static const _label = Color(0xFFA0471A);
  static const _brown = Color(0xFF8A4B14);
  static const _beige = Color(0xFFF3E8D6);
  static const _divider = Color(0xFFEBDDC3);
  static const _rowDivider = Color(0xFFF0EBE2);
  static const _cardBorder = Color(0xFFF1EDE6);
  static const _profitBg = Color(0xFFFFF5EC);
  static const _grey = Color(0xFF6B6B6B);
  static const _warnBg = Color(0xFFFFE3D1);
  static const _warnText = Color(0xFFB8470A);
  static const _okBg = Color(0xFFDDF3E4);
  static const _okText = Color(0xFF1E8449);

  /// Target HPP (food cost) dalam persen.
  static const double _targetHpp = 30;

  // ---------- Helper format ----------
  /// 22000 -> "Rp 22.000"
  static String _fmtRupiah(int v) {
    final s = v.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return 'Rp $buf';
  }

  /// 30.2 -> "30,2" ; 30 -> "30"
  static String _fmtNum(double v) {
    final s = v == v.roundToDouble() ? v.toInt().toString() : v.toString();
    return s.replaceAll('.', ',');
  }

  // ---------- Aksi Navigasi & Update ----------
  Future<void> _editDetail() async {
    final result = await Navigator.push<MenuModel>(
      context,
      MaterialPageRoute(builder: (_) => EditDetailMenuPage(menu: menu)),
    );
    // Jika user menekan "Simpan" (result tidak null), perbarui UI
    if (result != null) {
      setState(() => menu = result);
    }
  }

  Future<void> _editResep() async {
    final result = await Navigator.push<MenuModel>(
      context,
      MaterialPageRoute(builder: (_) => EditResepMenuPage(menu: menu)),
    );
    // Jika user menekan "Simpan Perubahan" (result tidak null), perbarui UI
    if (result != null) {
      setState(() => menu = result);
    }
  }

  // ------------------------------------------------------------
  // BUILD
  // ------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(25, 19, 25, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildImage(),
                  const SizedBox(height: 14),
                  Text(
                    menu.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: _textDark,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'ID: ${menu.id}',
                    style: const TextStyle(fontSize: 11, color: _grey),
                  ),
                  const SizedBox(height: 28),
                  
                  // Bagian Detail Menu
                  _buildSectionTitle('Detail Menu', onEdit: _editDetail),
                  const SizedBox(height: 16),
                  _buildDetailCard(),
                  const SizedBox(height: 26),
                  
                  // Bagian Rincian Resep
                  _buildSectionTitle('Rincian Resep', onEdit: _editResep),
                  const SizedBox(height: 14),
                  _buildRecipe(),
                  
                  // Profitabilitas muncul hanya jika resep tidak kosong
                  if (menu.hasRecipe) ...[
                    const SizedBox(height: 22),
                    _buildProfitCard(),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------- Header ----------
  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: _headerBg,
        boxShadow: [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 70,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 14),
                  child: IconButton(
                    // Saat pop halaman ini, bawa menu terakhir agar Daftar Menu ikut terupdate
                    onPressed: () => Navigator.pop(context, menu),
                    icon: const Icon(
                      Icons.arrow_back,
                      size: 22,
                      color: _textDark,
                    ),
                  ),
                ),
              ),
              const Text(
                'Informasi Menu',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: _textDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------- Foto ----------
  Widget _buildImage() {
    final fallback = Container(
      color: _beige,
      child: const Center(
        child: Icon(Icons.restaurant_menu, size: 48, color: _brown),
      ),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: SizedBox(
        width: double.infinity,
        height: 168,
        child: menu.imageAsset != null
            ? Image.asset(
                menu.imageAsset!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => fallback,
              )
            : fallback,
      ),
    );
  }

  // ---------- Judul section + tombol edit ----------
  Widget _buildSectionTitle(String title, {VoidCallback? onEdit}) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w700,
                color: _navy,
              ),
            ),
            InkWell(
              onTap: onEdit,
              borderRadius: BorderRadius.circular(20),
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(Icons.edit_outlined, size: 20, color: _navy),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Divider(height: 1, thickness: 1, color: _divider),
      ],
    );
  }

  // ---------- Kartu detail menu ----------
  Widget _buildDetailCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _cardBorder),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _detailRow('Nama Menu', menu.name),
          const Divider(height: 1, thickness: 1, color: _rowDivider),
          _detailRow('Kategori Menu', menu.category),
          const Divider(height: 1, thickness: 1, color: _rowDivider),
          _detailRow('Harga Jual', _fmtRupiah(menu.price)),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return SizedBox(
      height: 41,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 13, color: _label),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: _textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------- Daftar Resep ----------
  Widget _buildRecipe() {
    if (menu.recipe.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
        decoration: BoxDecoration(
          color: _beige.withOpacity(0.5),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: _divider),
        ),
        child: const Text(
          'Belum ada resep untuk menu ini.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13.5, color: _grey),
        ),
      );
    }

    return Column(
      children: [
        for (int i = 0; i < menu.recipe.length; i++) ...[
          if (i > 0) const SizedBox(height: 13),
          _recipeRow(menu.recipe[i]),
        ],
      ],
    );
  }

  Widget _recipeRow(RecipeItem r) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _brown, width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(7),
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    r.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 15, color: _textDark),
                  ),
                ),
              ),
            ),
            Container(
              width: 105,
              height: double.infinity,
              decoration: const BoxDecoration(
                color: _beige,
                border: Border(left: BorderSide(color: _brown, width: 1)),
              ),
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(left: 20),
              child: Text(
                '${_fmtNum(r.qty)} ${r.unit}',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: _brown,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- Analisa profitabilitas ----------
  Widget _buildProfitCard() {
    // Membaca perhitungan cost dinamis dari model resep baru
    final cost = menu.materialCost;
    final pct = menu.foodCost ?? 0.0;
    final margin = menu.price - cost;
    final overTarget = pct > _targetHpp;

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
      decoration: BoxDecoration(
        color: _profitBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _brown, width: 1),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.calculate_outlined, size: 16, color: _label),
              const SizedBox(width: 6),
              const Text(
                'ANALISA PROFITABILITAS',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                  color: _label,
                ),
              ),
              const Spacer(),
              Text(
                'Target HPP: ${_fmtNum(_targetHpp)}%',
                style: const TextStyle(fontSize: 11.5, color: _grey),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(height: 1, thickness: 1, color: _divider),
          const SizedBox(height: 4),
          _profitRow('Biaya bahan', _fmtRupiah(cost)),
          _profitRow('Margin', _fmtRupiah(margin)),
          const Divider(height: 1, thickness: 1, color: _divider),
          SizedBox(
            height: 38,
            child: Row(
              children: [
                const Text(
                  'Food cost',
                  style: TextStyle(fontSize: 13, color: _textDark),
                ),
                const Spacer(),
                Text(
                  '${_fmtNum(pct)}%',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _textDark,
                  ),
                ),
                const SizedBox(width: 8),
                _targetBadge(overTarget),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _profitRow(String label, String value) {
    return SizedBox(
      height: 30,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 13, color: _textDark),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: _textDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _targetBadge(bool overTarget) {
    final bg = overTarget ? _warnBg : _okBg;
    final fg = overTarget ? _warnText : _okText;
    final label = overTarget
        ? 'Di atas target ${_fmtNum(_targetHpp)}%'
        : 'Sesuai target';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            overTarget
                ? Icons.warning_amber_rounded
                : Icons.check_circle_outline,
            size: 13,
            color: fg,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}
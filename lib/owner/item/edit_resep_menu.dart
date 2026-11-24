import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'daftar_menu.dart';
import 'popup_pilihbahan.dart';

// =====================================================
// HALAMAN EDIT RINCIAN RESEP
// Dibuka dari ikon pensil "Rincian Resep" (InformasiMenuPage)
// atau tombol "Atur Rincian Resep & Bahan" (EditDetailMenuPage).
// Saat disimpan, mengembalikan MenuModel baru lewat Navigator.pop.
// =====================================================
class EditResepMenuPage extends StatefulWidget {
  final MenuModel menu;

  const EditResepMenuPage({super.key, required this.menu});

  @override
  State<EditResepMenuPage> createState() => _EditResepMenuPageState();
}

/// Satu baris bahan di form (menyimpan controller-nya sendiri).
class _RecipeRowData {
  final TextEditingController name;
  final TextEditingController qty;
  final String unit;
  final double unitPrice; // Rp per 1 satuan

  _RecipeRowData({
    required String name,
    required String qty,
    this.unit = 'g',
    this.unitPrice = 0,
  }) : name = TextEditingController(text: name),
       qty = TextEditingController(text: qty);

  double get qtyValue =>
      double.tryParse(qty.text.trim().replaceAll(',', '.')) ?? 0;

  void dispose() {
    name.dispose();
    qty.dispose();
  }
}

class _EditResepMenuPageState extends State<EditResepMenuPage> {
  // ---------- Warna (disesuaikan dengan desain) ----------
  static const _headerBg = Color(0xFFFBF7EE);
  static const _textDark = Color(0xFF1E1408);
  static const _brown = Color(0xFF8A4B14);
  static const _label = Color(0xFFA0471A);
  static const _beige = Color(0xFFF3E8D6);
  static const _orange = Color(0xFFE59E2C);
  static const _softPeach = Color(0xFFFFF0E5);
  static const _priceChip = Color(0xFFFBDDC0);
  static const _grey = Color(0xFF6B6B6B);
  static const _panelBorder = Color(0xFFE6D5BC);

  final List<_RecipeRowData> _rows = [];

  @override
  void initState() {
    super.initState();
    for (final r in widget.menu.recipe) {
      _rows.add(
        _RecipeRowData(
          name: r.name,
          qty: _fmtNum(r.qty),
          unit: r.unit,
          unitPrice: r.unitPrice,
        ),
      );
    }
  }

  @override
  void dispose() {
    for (final r in _rows) {
      r.dispose();
    }
    super.dispose();
  }

  // ---------- Helper format ----------
  static String _fmtRupiah(int v) {
    final s = v.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return 'Rp $buf';
  }

  static String _fmtNum(double v) {
    final s = v == v.roundToDouble() ? v.toInt().toString() : v.toString();
    return s.replaceAll('.', ',');
  }

  // ---------- Perhitungan ----------
  int get _cost => _rows
      .fold<double>(0, (sum, r) => sum + r.qtyValue * r.unitPrice)
      .round();

  double get _foodCost {
    if (widget.menu.price <= 0) return 0;
    final pct = _cost / widget.menu.price * 100;
    return (pct * 10).round() / 10; // 1 angka di belakang koma
  }

  // ---------- Aksi ----------
  Future<void> _showPilihBahan() async {
    final used = _rows.map((r) => r.name.text.trim().toLowerCase()).toSet();

    final picked = await showPilihBahanSheet(
      context,
      options: daftarBahanContoh, // TODO: ganti dengan data bahan dari API
      usedNames: used,
    );

    if (picked == null) return;
    setState(() {
      _rows.add(
        _RecipeRowData(
          name: picked.option.name,
          qty: _fmtNum(picked.qty),
          unit: picked.option.unit,
          unitPrice: picked.option.unitPrice,
        ),
      );
    });
  }

  void _removeRow(int i) {
    setState(() => _rows.removeAt(i).dispose());
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg)));
  }

  void _save() {
    if (_rows.isEmpty) return _showError('Tambahkan minimal satu bahan');
    for (final r in _rows) {
      if (r.name.text.trim().isEmpty || r.qtyValue <= 0) {
        return _showError('Nama bahan dan takaran wajib diisi');
      }
    }

    final m = widget.menu;
    // TODO: kirim perubahan resep ke API
    Navigator.pop(
      context,
      MenuModel(
        id: m.id,
        name: m.name,
        category: m.category,
        price: m.price,
        foodCost: _foodCost,
        recipe: _rows
            .map(
              (r) => RecipeItem(
                name: r.name.text.trim(),
                qty: r.qtyValue,
                unit: r.unit,
                unitPrice: r.unitPrice,
              ),
            )
            .toList(),
        imageAsset: m.imageAsset,
        icon: m.icon,
      ),
    );
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
              padding: const EdgeInsets.fromLTRB(25, 18, 25, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMenuCard(),
                  const SizedBox(height: 18),
                  _buildRecipeTitle(),
                  const SizedBox(height: 10),
                  for (int i = 0; i < _rows.length; i++) ...[
                    if (i > 0) const SizedBox(height: 10),
                    _buildRow(i),
                  ],
                  if (_rows.isNotEmpty) const SizedBox(height: 10),
                  _buildAddButton(),
                ],
              ),
            ),
          ),
          _buildBottomPanel(),
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
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.arrow_back,
                      size: 22,
                      color: _textDark,
                    ),
                  ),
                ),
              ),
              const Text(
                'Edit Informasi Menu',
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

  // ---------- Kartu ringkasan menu ----------
  Widget _buildMenuCard() {
    final m = widget.menu;
    final fallback = Container(
      color: _beige,
      child: const Icon(Icons.restaurant_menu, size: 26, color: _brown),
    );

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: _softPeach,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFF4DCC8)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              width: 64,
              height: 62,
              child: m.imageAsset != null
                  ? Image.asset(
                      m.imageAsset!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => fallback,
                    )
                  : fallback,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  m.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: _textDark,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  m.category,
                  style: const TextStyle(fontSize: 11, color: _grey),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
            decoration: BoxDecoration(
              color: _priceChip,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _fmtRupiah(m.price),
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: _brown,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------- Judul "Rincian Resep" ----------
  Widget _buildRecipeTitle() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Rincian Resep',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: _textDark,
              ),
            ),
            Text(
              'Takaran untuk satu porsi',
              style: TextStyle(fontSize: 12.5, color: _label),
            ),
          ],
        ),
        const Text(
          '*Wajib',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: _label,
          ),
        ),
      ],
    );
  }

  // ---------- Satu baris bahan ----------
  Widget _buildRow(int i) {
    final r = _rows[i];

    return SizedBox(
      height: 56,
      child: Row(
        children: [
          Expanded(
            child: Container(
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
                      child: TextField(
                        controller: r.name,
                        readOnly: true, // nama dipilih dari pop up
                        style: const TextStyle(
                          fontSize: 15,
                          color: _textDark,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Nama bahan',
                          hintStyle: TextStyle(
                            fontSize: 15,
                            color: Color(0xFF9A8F80),
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 15),
                        ),
                      ),
                    ),
                    Container(
                      width: 108,
                      height: double.infinity,
                      decoration: const BoxDecoration(
                        color: _beige,
                        border: Border(
                          left: BorderSide(color: _brown, width: 1),
                        ),
                      ),
                      padding: const EdgeInsets.only(left: 15),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 44,
                            child: TextField(
                              controller: r.qty,
                              keyboardType: const TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'[0-9.,]'),
                                ),
                              ],
                              onChanged: (_) => setState(() {}),
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: _brown,
                              ),
                              decoration: const InputDecoration(
                                hintText: '0',
                                hintStyle: TextStyle(
                                  fontSize: 15,
                                  color: Color(0xFFC9B79B),
                                ),
                                border: InputBorder.none,
                                isCollapsed: true,
                              ),
                            ),
                          ),
                          Text(
                            r.unit,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: _brown,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 11),
          // tombol hapus baris
          InkWell(
            onTap: () => _removeRow(i),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 60,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _brown, width: 1),
              ),
              child: const Icon(Icons.remove, size: 20, color: _textDark),
            ),
          ),
        ],
      ),
    );
  }

  // ---------- Tambah bahan (membuka pop up Pilih Bahan) ----------
  Widget _buildAddButton() {
    return Material(
      color: _softPeach,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: _showPilihBahan,
        child: const SizedBox(
          height: 56,
          width: double.infinity,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_circle_outline, size: 20, color: _textDark),
              SizedBox(width: 8),
              Text(
                'Tambah Bahan',
                style: TextStyle(
                  fontSize: 14,
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

  // ---------- Panel bawah: ringkasan biaya + tombol simpan ----------
  Widget _buildBottomPanel() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: _panelBorder, width: 1),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(25, 14, 25, 22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Rata-Rata Biaya per Porsi',
                      style: TextStyle(fontSize: 13, color: _label),
                    ),
                    Text(
                      _fmtRupiah(_cost),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: _textDark,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
                decoration: BoxDecoration(
                  color: _softPeach,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _brown, width: 1),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Food Cost',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: _label,
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${_fmtNum(_foodCost)}%',
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: _textDark,
                            height: 1.2,
                          ),
                        ),
                        Text(
                          'dari ${_fmtRupiah(widget.menu.price)}',
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: _label,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _orange,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: const Icon(Icons.check_circle_outline, size: 20),
                  label: const Text(
                    'Simpan Perubahan',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
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
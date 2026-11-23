import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Satu pilihan bahan di pop up "Pilih Bahan".
class BahanOption {
  final String name;
  final String category;
  final String unit;
  final double unitPrice; // Rp per 1 satuan
  final IconData icon;

  const BahanOption({
    required this.name,
    required this.category,
    required this.unit,
    required this.unitPrice,
    this.icon = Icons.inventory_2_outlined,
  });
}

/// Hasil dari pop up.
/// - mode resep    : [qty] terisi (takaran per porsi)
/// - mode supplier : [price] terisi (harga per satuan) + [isMain]
class PickedBahan {
  final BahanOption option;
  final double qty;
  final int price;
  final bool isMain;

  const PickedBahan(
    this.option,
    this.qty, {
    this.price = 0,
    this.isMain = false,
  });
}

/// Mode pop up:
/// - resep    : langkah 2 = "Takaran per Porsi" (dipakai halaman resep)
/// - supplier : langkah 2 = "Harga per Satuan" + toggle supplier utama
enum PilihBahanMode { resep, supplier }

// TODO: ganti dengan data bahan dari API
const List<BahanOption> daftarBahanContoh = [
  BahanOption(
    name: 'Susu UHT Full Cream',
    category: 'Minuman',
    unit: 'liter',
    unitPrice: 18000,
    icon: Icons.local_drink_outlined,
  ),
  BahanOption(
    name: 'Biji Kopi Arabika',
    category: 'Minuman',
    unit: 'kg',
    unitPrice: 150000,
    icon: Icons.coffee_outlined,
  ),
  BahanOption(
    name: 'Gula Pasir',
    category: 'Bahan Kering',
    unit: 'kg',
    unitPrice: 16000,
  ),
  BahanOption(
    name: 'Tepung Terigu',
    category: 'Bahan Kering',
    unit: 'kg',
    unitPrice: 12000,
  ),
];

/// Membuka pop up Pilih Bahan. Mengembalikan null jika ditutup tanpa memilih.
/// [onTambahBaru] dipanggil setelah pop up tertutup, saat tombol
/// "Bahan tidak ada? Tambah bahan baru" ditekan.
Future<PickedBahan?> showPilihBahanSheet(
  BuildContext context, {
  required List<BahanOption> options,
  Set<String> usedNames = const {},
  VoidCallback? onTambahBaru,
  PilihBahanMode mode = PilihBahanMode.resep,
  String usedLabel = 'Sudah di resep',
}) {
  FocusScope.of(context).unfocus();
  return showModalBottomSheet<PickedBahan>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => PilihBahanSheet(
      options: options,
      usedNames: usedNames,
      onTambahBaru: onTambahBaru,
      mode: mode,
      usedLabel: usedLabel,
    ),
  );
}

// =====================================================
// POP UP PILIH BAHAN (bottom sheet, 2 langkah)
// Langkah 1: daftar bahan
// Langkah 2: takaran (mode resep) / harga + supplier utama (mode supplier)
// Mengembalikan PickedBahan lewat Navigator.pop.
// =====================================================
class PilihBahanSheet extends StatefulWidget {
  final List<BahanOption> options;
  final Set<String> usedNames; // nama bahan (lowercase) yang sudah dipakai
  final VoidCallback? onTambahBaru;
  final PilihBahanMode mode;
  final String usedLabel;

  const PilihBahanSheet({
    super.key,
    required this.options,
    required this.usedNames,
    this.onTambahBaru,
    this.mode = PilihBahanMode.resep,
    this.usedLabel = 'Sudah di resep',
  });

  @override
  State<PilihBahanSheet> createState() => _PilihBahanSheetState();
}

class _PilihBahanSheetState extends State<PilihBahanSheet> {
  static const _textDark = Color(0xFF1E1408);
  static const _brown = Color(0xFF8A4B14);
  static const _beige = Color(0xFFF3E8D6);
  static const _softPeach = Color(0xFFFFF0E5);
  static const _cardBg = Color(0xFFFFF8F0);
  static const _divider = Color(0xFFEFE3D0);
  static const _grey = Color(0xFF6B6B6B);
  static const _orange = Color(0xFFE59E2C);
  static const _slate = Color(0xFF4A5F86); // chip aktif & footer
  static const _chipBg = Color(0xFFFFEBDD);
  static const _red = Color(0xFFD32F2F);

  final _search = TextEditingController();
  final _qty = TextEditingController();
  final _harga = TextEditingController();
  String _query = '';
  String _category = 'Semua';
  bool _utama = false;
  BahanOption? _selected; // null = langkah 1, terisi = langkah 2

  bool get _isSupplier => widget.mode == PilihBahanMode.supplier;

  List<String> get _categories => [
        'Semua',
        ...widget.options.map((o) => o.category).toSet(),
      ];

  @override
  void dispose() {
    _search.dispose();
    _qty.dispose();
    _harga.dispose();
    super.dispose();
  }

  double get _qtyValue =>
      double.tryParse(_qty.text.trim().replaceAll(',', '.')) ?? 0;

  int get _hargaInt =>
      int.tryParse(_harga.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

  static String _fmtRupiah(int v) {
    final s = v.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return 'Rp $buf';
  }

  void _select(BahanOption o) {
    FocusScope.of(context).unfocus();
    setState(() {
      _selected = o;
      _qty.clear();
      _harga.clear();
      _utama = false;
    });
  }

  void _back() {
    FocusScope.of(context).unfocus();
    setState(() => _selected = null);
  }

  void _submit() {
    if (_selected == null) return;
    if (_isSupplier) {
      if (_hargaInt <= 0) return;
      Navigator.pop(
        context,
        PickedBahan(_selected!, 0, price: _hargaInt, isMain: _utama),
      );
    } else {
      if (_qtyValue <= 0) return;
      Navigator.pop(context, PickedBahan(_selected!, _qtyValue));
    }
  }

  @override
  Widget build(BuildContext context) {
    final step2 = _selected != null;

    final content = Column(
      mainAxisSize: step2 ? MainAxisSize.min : MainAxisSize.max,
      children: [
        _buildTop(),
        if (step2)
          (_isSupplier ? _buildStep2Supplier() : _buildStep2Resep())
        else
          Expanded(child: _buildStep1()),
      ],
    );

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: step2
          ? content
          : SizedBox(
              height: MediaQuery.of(context).size.height * 0.85,
              child: content,
            ),
    );
  }

  // ---------- handle + judul + tombol tutup (dipakai kedua langkah) ----------
  Widget _buildTop() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 10),
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: const Color(0xFFD9C9B0),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 18, 24, 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Pilih Bahan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: _textDark,
                ),
              ),
              InkWell(
                onTap: () => Navigator.pop(context),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFE3CF),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.close, size: 20, color: _textDark),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: _divider),
      ],
    );
  }

  // ====================== LANGKAH 1: daftar bahan ======================
  Widget _buildStep1() {
    final list = widget.options.where((o) {
      final cocokNama = o.name.toLowerCase().contains(_query.toLowerCase());
      final cocokKategori = _category == 'Semua' || o.category == _category;
      return cocokNama && cocokKategori;
    }).toList();

    return Column(
      children: [
        // ===== Pencarian =====
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 14, 24, 14),
          child: TextField(
            controller: _search,
            onChanged: (v) => setState(() => _query = v),
            style: const TextStyle(fontSize: 14, color: _textDark),
            decoration: InputDecoration(
              hintText: 'Cari nama bahan',
              hintStyle: const TextStyle(
                fontSize: 14,
                color: Color(0xFF9A8F80),
              ),
              prefixIcon: const Icon(Icons.search, color: _brown),
              filled: true,
              fillColor: _softPeach,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 13),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFF4DCC8)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: _brown),
              ),
            ),
          ),
        ),

        // ===== Chip kategori =====
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final c = _categories[i];
              final aktif = c == _category;
              return GestureDetector(
                onTap: () => setState(() => _category = c),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: aktif ? _slate : _chipBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    c,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: aktif ? Colors.white : _brown,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 14),

        // ===== Daftar =====
        Expanded(
          child: list.isEmpty
              ? const Center(
                  child: Text(
                    'Bahan tidak ditemukan',
                    style: TextStyle(color: _grey),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: list.length,
                  separatorBuilder: (_, __) =>
                      const Divider(height: 1, color: _divider),
                  itemBuilder: (_, i) => _buildItem(list[i]),
                ),
        ),

        // ===== Footer =====
        _buildFooter(),
      ],
    );
  }

  Widget _buildItem(BahanOption o) {
    final used = widget.usedNames.contains(o.name.toLowerCase());

    return InkWell(
      onTap: used ? null : () => _select(o),
      child: Opacity(
        opacity: used ? 0.55 : 1,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              _iconBox(o),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      o.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: _textDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${o.category} · ${o.unit}',
                      style: const TextStyle(fontSize: 13, color: _brown),
                    ),
                  ],
                ),
              ),
              if (used)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: _beige,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    widget.usedLabel,
                    style: const TextStyle(fontSize: 11, color: _brown),
                  ),
                )
              else
                const Icon(Icons.chevron_right, size: 22, color: _brown),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFFFCF9F5),
        border: Border(top: BorderSide(color: _divider)),
      ),
      child: SafeArea(
        top: false,
        child: InkWell(
          onTap: () {
            final cb = widget.onTambahBaru;
            Navigator.pop(context);
            cb?.call();
          },
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 22),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_circle_outline, size: 18, color: _slate),
                SizedBox(width: 8),
                Text(
                  'Bahan tidak ada? Tambah bahan baru',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _slate,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _iconBox(BahanOption o) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: _beige,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(o.icon, size: 20, color: _brown),
    );
  }

  // =========== LANGKAH 2 (mode SUPPLIER): harga per satuan + supplier utama ===========
  Widget _buildStep2Supplier() {
    final o = _selected!;
    final canSubmit = _hargaInt > 0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ----- kartu bahan terpilih -----
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _cardBg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFF4DCC8)),
            ),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFBE8D3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(o.icon, size: 22, color: _brown),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        o.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: _textDark,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${o.category} • ${o.unit}',
                        style: const TextStyle(fontSize: 12.5, color: _brown),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),

          // ----- label harga -----
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Harga per Satuan (Rp)',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: _textDark,
                ),
              ),
              Text(
                '*Wajib',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // ----- input harga -----
          Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _brown, width: 1),
            ),
            child: Row(
              children: [
                const Text(
                  'Rp',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: _brown,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _harga,
                    autofocus: true,
                    onChanged: (_) => setState(() {}),
                    keyboardType: TextInputType.number,
                    inputFormatters: [_HargaFormatter()],
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: _textDark,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Contoh: 45.000',
                      hintStyle: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFFB8A98F),
                      ),
                      border: InputBorder.none,
                      isCollapsed: true,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '/${o.unit}',
                  style: const TextStyle(fontSize: 14, color: _textDark),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ----- toggle supplier utama -----
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
            decoration: BoxDecoration(
              color: _cardBg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _divider),
            ),
            child: Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Jadikan supplier utama',
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                          color: _textDark,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Pilihan otomatis saat\nmembuat resep & PO',
                        style: TextStyle(
                          fontSize: 12.5,
                          color: _brown,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _utama,
                  onChanged: (v) => setState(() => _utama = v),
                  activeColor: Colors.white,
                  activeTrackColor: _orange,
                  inactiveThumbColor: Colors.white,
                  inactiveTrackColor: const Color(0xFFD3CBBE),
                  trackOutlineColor:
                      const WidgetStatePropertyAll(Colors.transparent),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ----- tombol -----
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: canSubmit ? _submit : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _orange,
                foregroundColor: Colors.white,
                disabledBackgroundColor: const Color(0xFFF1D9A8),
                disabledForegroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Tambahkan ke Daftar',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          Center(
            child: TextButton(
              onPressed: _back,
              child: const Text(
                'Kembali',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2B3A67),
                ),
              ),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
        ],
      ),
    );
  }

  // ====================== LANGKAH 2 (mode RESEP): takaran per porsi ======================
  Widget _buildStep2Resep() {
    final o = _selected!;
    final cost = (_qtyValue * o.unitPrice).round();
    final canSubmit = _qtyValue > 0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // bahan terpilih
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          decoration: const BoxDecoration(
            color: Color(0xFFFFF5EC),
            border: Border(bottom: BorderSide(color: Color(0xFFF4DCC8))),
          ),
          child: Row(
            children: [
              _iconBox(o),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      o.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: _textDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      o.category,
                      style: const TextStyle(fontSize: 13, color: _brown),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Takaran per Porsi',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: _textDark,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 56,
                      child: TextField(
                        controller: _qty,
                        autofocus: true,
                        onChanged: (_) => setState(() {}),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                        ],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: _textDark,
                        ),
                        decoration: InputDecoration(
                          hintText: '0',
                          hintStyle: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFFC9B79B),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: _brown,
                              width: 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: _brown,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // satuan (terkunci, mengikuti bahan)
                  Container(
                    width: 90,
                    height: 56,
                    decoration: BoxDecoration(
                      color: _beige,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: _brown, width: 1),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          o.unit,
                          style: const TextStyle(
                            fontSize: 15,
                            color: _brown,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.lock_outline,
                          size: 14,
                          color: _brown,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              // biaya takaran
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 15,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8EFE2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _divider),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.payments_outlined, size: 18, color: _grey),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Biaya takaran',
                        style: TextStyle(fontSize: 13, color: _grey),
                      ),
                    ),
                    Text(
                      _fmtRupiah(cost),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: _textDark,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: canSubmit ? _submit : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _orange,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: const Color(0xFFF1D9A8),
                    disabledForegroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Tambahkan ke Resep',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              Center(
                child: TextButton(
                  onPressed: _back,
                  child: const Text(
                    'Kembali',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2B3A67),
                    ),
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
            ],
          ),
        ),
      ],
    );
  }
}

/// Format ribuan: 45000 -> 45.000 (maks 9 digit).
class _HargaFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    var d = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (d.length > 9) d = d.substring(0, 9);
    if (d.isEmpty) return const TextEditingValue(text: '');
    final buf = StringBuffer();
    for (var i = 0; i < d.length; i++) {
      if (i > 0 && (d.length - i) % 3 == 0) buf.write('.');
      buf.write(d[i]);
    }
    final text = buf.toString();
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
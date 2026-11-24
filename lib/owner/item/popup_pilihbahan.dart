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

/// Hasil dari pop up: bahan yang dipilih + takarannya.
class PickedBahan {
  final BahanOption option;
  final double qty;

  const PickedBahan(this.option, this.qty);
}


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
];

/// Membuka pop up Pilih Bahan. Mengembalikan null jika ditutup tanpa memilih.
Future<PickedBahan?> showPilihBahanSheet(
  BuildContext context, {
  required List<BahanOption> options,
  Set<String> usedNames = const {},
}) {
  FocusScope.of(context).unfocus();
  return showModalBottomSheet<PickedBahan>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => PilihBahanSheet(options: options, usedNames: usedNames),
  );
}

// =====================================================
// POP UP PILIH BAHAN (bottom sheet, 2 langkah)
// Langkah 1: daftar bahan  ->  Langkah 2: isi takaran per porsi
// Mengembalikan PickedBahan lewat Navigator.pop.
// =====================================================
class PilihBahanSheet extends StatefulWidget {
  final List<BahanOption> options;
  final Set<String> usedNames; // nama bahan (lowercase) yang sudah di resep

  const PilihBahanSheet({required this.options, required this.usedNames});

  @override
  State<PilihBahanSheet> createState() => _PilihBahanSheetState();
}

class _PilihBahanSheetState extends State<PilihBahanSheet> {
  static const _textDark = Color(0xFF1E1408);
  static const _brown = Color(0xFF8A4B14);
  static const _beige = Color(0xFFF3E8D6);
  static const _softPeach = Color(0xFFFFF0E5);
  static const _divider = Color(0xFFEFE3D0);
  static const _grey = Color(0xFF6B6B6B);
  static const _orange = Color(0xFFE59E2C);

  final _search = TextEditingController();
  final _qty = TextEditingController();
  String _query = '';
  BahanOption? _selected; // null = langkah 1, terisi = langkah 2

  @override
  void dispose() {
    _search.dispose();
    _qty.dispose();
    super.dispose();
  }

  double get _qtyValue =>
      double.tryParse(_qty.text.trim().replaceAll(',', '.')) ?? 0;

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
    });
  }

  void _back() {
    FocusScope.of(context).unfocus();
    setState(() => _selected = null);
  }

  void _submit() {
    if (_selected == null || _qtyValue <= 0) return;
    Navigator.pop(context, PickedBahan(_selected!, _qtyValue));
  }

  @override
  Widget build(BuildContext context) {
    final step2 = _selected != null;

    final content = Column(
      mainAxisSize: step2 ? MainAxisSize.min : MainAxisSize.max,
      children: [
        _buildTop(),
        if (step2) _buildStep2() else Expanded(child: _buildStep1()),
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
    final list = widget.options
        .where((o) => o.name.toLowerCase().contains(_query.toLowerCase()))
        .toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 14, 24, 10),
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
                  child: const Text(
                    'Sudah di resep',
                    style: TextStyle(fontSize: 11, color: _brown),
                  ),
                ),
            ],
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

  // ====================== LANGKAH 2: takaran per porsi ======================
  Widget _buildStep2() {
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
import 'package:flutter/material.dart';

import '../../constants/ingredient_options.dart';
import '../partials/colors.dart';

/// Urutan grup yang ditampilkan di sheet (daftar satuannya dari kUnits).
const List<String> _kGrup = ['BERAT', 'VOLUME', 'HITUNGAN'];

// =====================================================
// FUNGSI PEMBUKA SHEET
// Mengembalikan KUNCI satuan terpilih (mis. "kg", "l", "x:karung"),
// atau null jika ditutup tanpa memilih.
// [current] juga berupa kunci satuan.
// =====================================================
Future<String?> showPilihSatuanSheet(BuildContext context, {String? current}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _PilihSatuanSheet(current: current),
  );
}

// =====================================================
// SHEET
// =====================================================
class _PilihSatuanSheet extends StatefulWidget {
  final String? current;
  const _PilihSatuanSheet({this.current});

  @override
  State<_PilihSatuanSheet> createState() => _PilihSatuanSheetState();
}

class _PilihSatuanSheetState extends State<_PilihSatuanSheet> {
  // Warna khusus sheet ini (diambil dari desain)
  static const Color _sheetBg = AppColors.sheetBg;
  static const Color _handle = AppColors.sheetHandle;
  static const Color _sectionText = AppColors.sectionText;
  static const Color _selectedBg = AppColors.selectedBg;
  static const Color _divider = AppColors.sheetDivider;
  static const Color _radioOff = AppColors.sheetRadioOff;
  static const Color _subText = AppColors.subtitle;
  static const Color _btn = AppColors.orangeAccent;

  String? _selected; // kunci satuan
  final List<String> _custom = []; // kunci satuan khusus ("x:...")

  @override
  void initState() {
    super.initState();
    _selected = widget.current;

    // Jika satuan sebelumnya adalah satuan khusus, tampilkan lagi.
    final cur = widget.current;
    if (cur != null && isCustomUnit(cur)) _custom.add(cur);
  }

  // ---------- Tambah satuan khusus ----------
  Future<void> _tambahKhusus() async {
    final ctrl = TextEditingController();

    final hasil = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _sheetBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text(
          'Tambah satuan khusus',
          style: TextStyle(
            fontFamily: kFont,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          maxLength: 15,
          style: const TextStyle(
            fontFamily: kFont,
            fontSize: 14,
            color: AppColors.textDark,
          ),
          decoration: InputDecoration(
            counterText: '',
            hintText: 'Contoh: karung, ikat, dus',
            hintStyle: const TextStyle(
              fontFamily: kFont,
              fontSize: 14,
              color: AppColors.mutedText,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.brown),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.brown, width: 1.5),
            ),
          ),
          onSubmitted: (v) => Navigator.pop(ctx, v.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Batal',
              style: TextStyle(fontFamily: kFont, color: _subText),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
            child: const Text(
              'Simpan',
              style: TextStyle(
                fontFamily: kFont,
                fontWeight: FontWeight.w600,
                color: AppColors.brownDark,
              ),
            ),
          ),
        ],
      ),
    );

    if (!mounted || hasil == null || hasil.isEmpty) return;

    // Kalau ternyata sama dengan satuan bawaan (mis. "Liter", "gram"),
    // pilih satuan bawaan itu, jangan dibuat ganda.
    final lower = hasil.toLowerCase();
    String? matchKey;
    for (final u in kUnits) {
      if (u.key == lower ||
          u.label.toLowerCase() == lower ||
          u.name?.toLowerCase() == lower) {
        matchKey = u.key;
      }
    }

    final key = matchKey ?? customUnitKey(hasil);
    setState(() {
      if (matchKey == null && !_custom.contains(key)) _custom.add(key);
      _selected = key;
    });
  }

  // ---------- BUILD ----------
  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);

    return Container(
      height: media.size.height * 0.75,
      decoration: const BoxDecoration(
        color: _sheetBg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 10),
          // Handle
          Container(
            width: 42,
            height: 4,
            decoration: BoxDecoration(
              color: _handle,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          // Judul + tombol tutup
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 12, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Pilih Satuan',
                  style: TextStyle(
                    fontFamily: kFont,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => Navigator.pop(context),
                  child: const Padding(
                    padding: EdgeInsets.all(6),
                    child: Icon(
                      Icons.close,
                      size: 24,
                      color: AppColors.textDark,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Daftar satuan (bisa di-scroll)
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 8),
              children: [
                ..._kGrup.expand(
                      (g) => _buildSection(
                    g,
                    kUnits.where((u) => u.group == g).toList(),
                  ),
                ),
                if (_custom.isNotEmpty)
                  ..._buildSection('KUSTOM', _custom.map(unitByKey).toList()),
              ],
            ),
          ),
          // Tombol pilih
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _selected == null
                    ? null
                    : () => Navigator.pop(context, _selected),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _btn,
                  disabledBackgroundColor: _btn.withOpacity(0.5),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: const Text(
                  'Pilih Satuan',
                  style: TextStyle(
                    fontFamily: kFont,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          // Tambah satuan khusus
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _tambahKhusus,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.add_circle_outline, size: 18, color: _sectionText),
                  SizedBox(width: 6),
                  Text(
                    'Tambah satuan khusus',
                    style: TextStyle(
                      fontFamily: kFont,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w500,
                      color: _sectionText,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: media.padding.bottom),
        ],
      ),
    );
  }

  // ---------- Satu grup (judul + baris-baris) ----------
  List<Widget> _buildSection(String title, List<UnitOption> items) {
    return [
      Padding(
        padding: const EdgeInsets.fromLTRB(4, 14, 0, 6),
        child: Text(
          title,
          style: const TextStyle(
            fontFamily: kFont,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
            color: _sectionText,
          ),
        ),
      ),
      ...items.map(_buildRow),
    ];
  }

  // ---------- Satu baris satuan ----------
  Widget _buildRow(UnitOption u) {
    final selected = _selected == u.key;

    return InkWell(
      onTap: () => setState(() => _selected = u.key),
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: selected ? _selectedBg : Colors.white,
          border: const Border(bottom: BorderSide(color: _divider)),
        ),
        child: Row(
          children: [
            Text(
              u.label,
              style: const TextStyle(
                fontFamily: kFont,
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
            if (u.name != null) ...[
              const SizedBox(width: 8),
              Text(
                '(${u.name})',
                style: const TextStyle(
                  fontFamily: kFont,
                  fontSize: 11.5,
                  color: _subText,
                ),
              ),
            ],
            const Spacer(),
            _buildRadio(selected),
          ],
        ),
      ),
    );
  }

  Widget _buildRadio(bool selected) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(color: selected ? _btn : _radioOff, width: 2),
      ),
      child: selected
          ? Center(
        child: Container(
          width: 10,
          height: 10,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.textDark,
          ),
        ),
      )
          : null,
    );
  }
}
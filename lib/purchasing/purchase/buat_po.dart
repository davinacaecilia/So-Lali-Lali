import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../partials/colors.dart';
import 'pilih_bahan.dart';
import 'review_po.dart';

enum BuatPoMode { dariRequest, manual }

// ============================ MODEL ============================
/// Item yang dikirim dari Detail Request (mode dariRequest).
class BuatPoItem {
  final String name;
  final double qty;
  final String unit;
  final bool sudahPo;
  final String? supplier; // terisi jika sudahPo

  const BuatPoItem({
    required this.name,
    required this.qty,
    required this.unit,
    this.sudahPo = false,
    this.supplier,
  });
}

// TODO FE: ganti dengan item dari request yang dipilih
const List<BuatPoItem> _dummyRequestItems = [
  BuatPoItem(name: 'Biji Kopi Arabika', qty: 2, unit: 'kg'),
  BuatPoItem(name: 'Susu UHT Full Cream', qty: 2, unit: 'liter'),
  BuatPoItem(
    name: 'Gula Pasir',
    qty: 2,
    unit: 'kg',
    sudahPo: true,
    supplier: 'PT Abdi Jaya',
  ),
];

// TODO FE: ganti dengan daftar supplier dari API
const List<String> _suppliers = ['PT Abdi Jaya', 'PT Jaya Abdi', 'CV Sumber Rasa'];

/// State baris item di halaman ini.
class _Row {
  final String name;
  final String unit;
  final bool sudahPo;
  double qty;
  String? supplier;
  bool checked;

  _Row({
    required this.name,
    required this.unit,
    required this.qty,
    this.sudahPo = false,
    this.supplier,
    this.checked = true,
  });
}

// ============================ PAGE ============================
class BuatPoPage extends StatefulWidget {
  final BuatPoMode mode;
  final String? requestCode;
  final List<BuatPoItem> items;

  /// Dari Detail Request.
  const BuatPoPage.dariRequest({
    super.key,
    required this.requestCode,
    this.items = _dummyRequestItems,
  }) : mode = BuatPoMode.dariRequest;

  /// Dari tombol "+" di daftar PO.
  const BuatPoPage.manual({super.key})
      : mode = BuatPoMode.manual,
        requestCode = null,
        items = const [];

  @override
  State<BuatPoPage> createState() => _BuatPoPageState();
}

class _BuatPoPageState extends State<BuatPoPage> {
  late final List<_Row> _rows;

  bool get _fromRequest => widget.mode == BuatPoMode.dariRequest;

  @override
  void initState() {
    super.initState();
    _rows = [
      for (final e in widget.items)
        _Row(
          name: e.name,
          unit: e.unit,
          qty: e.qty,
          sudahPo: e.sudahPo,
          supplier: e.supplier,
          checked: !e.sudahPo, // default: semua item "Belum PO" tercentang
        ),
    ];
  }

  /// Item yang akan masuk PO baru.
  List<_Row> get _selected => _rows
      .where((r) => !r.sudahPo && (_fromRequest ? r.checked : true))
      .toList();

  bool get _valid =>
      _selected.isNotEmpty &&
      _selected.every((r) => r.supplier != null && r.qty > 0);

  /// supplier -> jumlah item (1 supplier = 1 PO)
  Map<String, int> get _perSupplier {
    final m = <String, int>{};
    for (final r in _selected) {
      if (r.supplier == null) continue;
      m[r.supplier!] = (m[r.supplier!] ?? 0) + 1;
    }
    return m;
  }

  Future<void> _tambahBahan() async {
    final picked = await showPilihBahan(
      context,
      alreadyAdded: _rows.map((r) => r.name).toSet(),
    );
    if (picked == null) return;
    setState(() => _rows.add(_Row(name: picked.name, unit: picked.unit, qty: 1)));
  }

  void _next() {
    final groups = <String, List<PoReviewItem>>{};
    for (final r in _selected) {
      groups
          .putIfAbsent(r.supplier!, () => [])
          .add(PoReviewItem(name: r.name, unit: r.unit, qty: r.qty));
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReviewPoPage(
          groups: [
            for (final e in groups.entries)
              PoReviewGroup(supplier: e.key, items: e.value),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const _TopBar(title: 'Buat Purchase Order'),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(25, 20, 25, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_fromRequest) ...[
                    _RequestBanner(code: widget.requestCode!),
                    const SizedBox(height: 18),
                  ],
                  const _SectionTitle('Pilih Item'),
                  const SizedBox(height: 12),
                  if (_rows.isEmpty)
                    const _EmptyState(),
                  for (final r in _rows) ...[
                    _ItemCard(
                      key: ObjectKey(r),
                      row: r,
                      showCheckbox: _fromRequest,
                      editableQty: !_fromRequest,
                      onChecked: (v) => setState(() => r.checked = v),
                      onSupplier: (v) => setState(() => r.supplier = v),
                      onQty: (v) => setState(() => r.qty = v),
                      onDelete: _fromRequest
                          ? null
                          : () => setState(() => _rows.remove(r)),
                    ),
                    const SizedBox(height: 12),
                  ],
                  if (!_fromRequest) _AddBahanButton(onTap: _tambahBahan),
                ],
              ),
            ),
          ),
          // ---------- Ringkasan + tombol (nempel di bawah) ----------
          Padding(
            padding: EdgeInsets.fromLTRB(
              25,
              8,
              25,
              MediaQuery.of(context).padding.bottom + 16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _Summary(perSupplier: _perSupplier),
                const SizedBox(height: 12),
                _NextButton(enabled: _valid, onTap: _next),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================ TOP BAR ============================
class _TopBar extends StatelessWidget {
  final String title;

  const _TopBar({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 24,
        bottom: 24,
        left: 20,
        right: 20,
      ),
      decoration: BoxDecoration(
        color: AppColors.headerBg,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: InkWell(
              onTap: () => Navigator.maybePop(context),
              customBorder: const CircleBorder(),
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(Icons.arrow_back,
                    color: AppColors.brownDark, size: 24),
              ),
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.brownDark,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================ BANNER & JUDUL ============================
class _RequestBanner extends StatelessWidget {
  final String code;

  const _RequestBanner({required this.code});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.navActiveBg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text.rich(
        TextSpan(
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12,
            color: AppColors.brown,
          ),
          children: [
            const TextSpan(text: 'Dari Request '),
            TextSpan(
              text: code,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            text,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 4),
          const Divider(height: 1, thickness: 1, color: AppColors.cardBorder),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: Text(
          'Belum ada bahan. Tekan "Tambah Bahan" untuk memilih.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12,
            color: AppColors.subText,
          ),
        ),
      ),
    );
  }
}

// ============================ KARTU ITEM ============================
class _ItemCard extends StatelessWidget {
  final _Row row;
  final bool showCheckbox; // true = dari request
  final bool editableQty; // true = manual
  final ValueChanged<bool> onChecked;
  final ValueChanged<String?> onSupplier;
  final ValueChanged<double> onQty;
  final VoidCallback? onDelete;

  const _ItemCard({
    super.key,
    required this.row,
    required this.showCheckbox,
    required this.editableQty,
    required this.onChecked,
    required this.onSupplier,
    required this.onQty,
    required this.onDelete,
  });

  // Dropdown aktif hanya jika item ikut dibuat PO.
  bool get _active => !row.sudahPo && (!showCheckbox || row.checked);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.cardBorder, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---------- Baris nama ----------
          Row(
            children: [
              if (showCheckbox) ...[
                _Checkbox(
                  value: row.checked,
                  disabled: row.sudahPo,
                  onChanged: onChecked,
                ),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(
                  row.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _active || !showCheckbox
                        ? AppColors.brownDark
                        : AppColors.subText,
                  ),
                ),
              ),
              if (row.sudahPo) ...[
                const SizedBox(width: 6),
                const _SudahPoChip(),
              ],
              const Spacer(),
              if (editableQty)
                Transform.translate(
                  offset: const Offset(8, 0),
                  child: _QtyField(row: row, onChanged: onQty),
                )
              else
                _QtyChip(text: '${formatQty(row.qty)} ${row.unit}'),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Supplier',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: AppColors.menungguText,
            ),
          ),
          const SizedBox(height: 3),
          _SupplierDropdown(
            value: row.supplier,
            enabled: _active,
            onChanged: onSupplier,
          ),
          if (onDelete != null) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: InkWell(
                onTap: onDelete,
                borderRadius: BorderRadius.circular(4),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.delete_outline_rounded,
                          size: 15, color: AppColors.red),
                      SizedBox(width: 4),
                      Text(
                        'Hapus',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: AppColors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Checkbox extends StatelessWidget {
  final bool value;
  final bool disabled;
  final ValueChanged<bool> onChanged;

  const _Checkbox({
    required this.value,
    required this.disabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final bool on = value && !disabled;
    return GestureDetector(
      onTap: disabled ? null : () => onChanged(!value),
      child: Container(
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          color: disabled
              ? const Color(0xFFE3E0DA)
              : (on ? AppColors.brown : Colors.white),
          borderRadius: BorderRadius.circular(5),
          border: Border.all(
            color: disabled ? const Color(0xFFCFCBC3) : AppColors.brown,
            width: 1.2,
          ),
        ),
        child: on
            ? const Icon(Icons.check, size: 16, color: Colors.white)
            : null,
      ),
    );
  }
}

class _SudahPoChip extends StatelessWidget {
  const _SudahPoChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.disetujuiBg,
        borderRadius: BorderRadius.circular(3),
        border: Border.all(
          color: AppColors.disetujuiText.withOpacity(0.35),
          width: 0.8,
        ),
      ),
      child: const Text(
        'Sudah PO',
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 9,
          fontWeight: FontWeight.w500,
          color: AppColors.disetujuiText,
        ),
      ),
    );
  }
}

/// Qty read-only (mode dari request).
class _QtyChip extends StatelessWidget {
  final String text;

  const _QtyChip({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.navActiveBg,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.cardBorder, width: 1),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.brownDark,
        ),
      ),
    );
  }
}

/// Qty bisa diisi (mode manual).
class _QtyField extends StatelessWidget {
  final _Row row;
  final ValueChanged<double> onChanged;

  const _QtyField({required this.row, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    const TextStyle style = TextStyle(
      fontFamily: 'Poppins',
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: AppColors.brownDark,
    );

    return Container(
      width: 84,
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.brown, width: 1),
      ),
      child: TextFormField(
        initialValue: formatQty(row.qty),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
        style: style,
        onChanged: (v) => onChanged(double.tryParse(v.replaceAll(',', '.')) ?? 0),
        decoration: InputDecoration(
          isDense: true,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
          suffixText: row.unit,
          suffixStyle: style.copyWith(color: AppColors.subText),
        ),
      ),
    );
  }
}

class _SupplierDropdown extends StatelessWidget {
  final String? value;
  final bool enabled;
  final ValueChanged<String?> onChanged;

  const _SupplierDropdown({
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    const TextStyle style = TextStyle(
      fontFamily: 'Poppins',
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: AppColors.brownDark,
    );
    final options = <String>{..._suppliers, if (value != null) value!}.toList();

    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: enabled ? Colors.white : AppColors.navActiveBg,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: enabled ? AppColors.brown : AppColors.cardBorder,
          width: 1,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: value,
          style: style,
          icon: const Icon(Icons.keyboard_arrow_down_rounded,
              color: AppColors.brown),
          hint: Text(
            'Pilih supplier',
            style: style.copyWith(color: AppColors.subText.withOpacity(0.7)),
          ),
          items: [
            for (final s in options)
              DropdownMenuItem(value: s, child: Text(s, style: style)),
          ],
          onChanged: enabled ? onChanged : null,
        ),
      ),
    );
  }
}

// ============================ TAMBAH BAHAN ============================
class _AddBahanButton extends StatelessWidget {
  final VoidCallback onTap;

  const _AddBahanButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: double.infinity,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.iconTile.withOpacity(0.7),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.cardBorder, width: 1),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle_outline, size: 18, color: AppColors.brown),
            SizedBox(width: 8),
            Text(
              'Tambah Bahan',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.brown,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================ RINGKASAN & TOMBOL ============================
class _Summary extends StatelessWidget {
  final Map<String, int> perSupplier;

  const _Summary({required this.perSupplier});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxHeight: 130),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.filterItemBg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              perSupplier.isEmpty
                  ? 'Belum ada PO yang akan dibuat'
                  : '${perSupplier.length} PO akan Dibuat',
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.brownDark,
              ),
            ),
            for (final e in perSupplier.entries) ...[
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    e.key,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11,
                      color: AppColors.brown,
                    ),
                  ),
                  Text(
                    '${e.value} item',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.brown,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _NextButton extends StatelessWidget {
  final bool enabled;
  final VoidCallback onTap;

  const _NextButton({required this.enabled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final Color fg = enabled ? Colors.white : AppColors.brown;
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: double.infinity,
        height: 48,
        decoration: BoxDecoration(
          color: enabled ? AppColors.orange : AppColors.tilePeach,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Berikutnya',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: fg,
              ),
            ),
            const SizedBox(width: 6),
            Icon(Icons.arrow_forward, size: 16, color: fg),
          ],
        ),
      ),
    );
  }
}
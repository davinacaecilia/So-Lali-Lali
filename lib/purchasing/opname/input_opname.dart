import 'package:flutter/material.dart';

import '../partials/colors.dart';
import '../terima/terima_common.dart';
import 'hasil_opname.dart';
import 'opname_page.dart';

// ============================ INPUT STOCK OPNAME ============================
class InputOpnamePage extends StatefulWidget {
  const InputOpnamePage({super.key});

  @override
  State<InputOpnamePage> createState() => _InputOpnamePageState();
}

class _InputOpnamePageState extends State<InputOpnamePage> {
  final List<OpnameItem> _items = dummyOpnameItems();
  static const _cats = ['Semua', 'Bahan Kering', 'Bahan Cair'];
  int _cat = 0;
  String _q = '';

  int get _done => _items.where((e) => e.physical != null).length;

  Future<void> _open(OpnameItem it) async {
    await showDetailStockSheet(context, it);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final list = _items
        .where((e) =>
            (_cat == 0 || e.category == _cats[_cat]) &&
            e.name.toLowerCase().contains(_q.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const TerimaTopBar(title: 'Input Stock Opname'),
          Padding(
            padding: const EdgeInsets.fromLTRB(25, 14, 25, 0),
            child: Column(children: [
              Row(children: [
                Expanded(child: Text('Progress Opname', style: ts(11, FontWeight.w500, AppColors.brownDark))),
                Text('$_done/${_items.length} Bahan', style: ts(11, FontWeight.w600, AppColors.brown)),
              ]),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: _done / _items.length,
                  minHeight: 6,
                  backgroundColor: AppColors.filterItemSelectedBg,
                  valueColor: const AlwaysStoppedAnimation(AppColors.orange),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => Navigator.push(
                    context, MaterialPageRoute(builder: (_) => ScanBahanPage(items: _items))).then((_) => setState(() {})),
                icon: const Icon(Icons.qr_code_scanner, size: 18, color: AppColors.primary),
                label: Text('Scan Barcode', style: ts(13, FontWeight.w600, AppColors.primary)),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 42),
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                height: 42,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: AppColors.cardWarnBg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.cardWarnBorder),
                ),
                child: Row(children: [
                  const Icon(Icons.search, size: 20, color: AppColors.iconBrown),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      onChanged: (v) => setState(() => _q = v),
                      style: ts(13, FontWeight.w400, AppColors.brownDark),
                      decoration: InputDecoration(
                        isDense: true,
                        border: InputBorder.none,
                        hintText: 'Cari nama bahan',
                        hintStyle: ts(13, FontWeight.w400, AppColors.subText.withOpacity(0.7)),
                      ),
                    ),
                  ),
                ]),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 30,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _cats.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 6),
                  itemBuilder: (_, i) => GestureDetector(
                    onTap: () => setState(() => _cat = i),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: i == _cat ? AppColors.primary : AppColors.filterItemBg,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(_cats[i],
                          style: ts(12, FontWeight.w600, i == _cat ? Colors.white : AppColors.brown)),
                    ),
                  ),
                ),
              ),
            ]),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(25, 12, 25, 12),
              itemCount: list.length,
              separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.divider),
              itemBuilder: (_, i) {
                final it = list[i];
                return InkWell(
                  onTap: () => _open(it),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(children: [
                      Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(color: AppColors.iconTile, borderRadius: BorderRadius.circular(8)),
                        child: const Icon(Icons.inventory_2, size: 22, color: AppColors.iconBrown),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Row(children: [
                            Flexible(child: Text(it.name, style: ts(13, FontWeight.w600, AppColors.brownDark))),
                            if (it.physical != null)
                              const Padding(
                                padding: EdgeInsets.only(left: 4),
                                child: Icon(Icons.check_circle, size: 16, color: AppColors.disetujuiText),
                              ),
                          ]),
                          Text(it.category, style: ts(10, FontWeight.w400, AppColors.subText)),
                        ]),
                      ),
                      Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                        Text('Stok Sistem', style: ts(9, FontWeight.w400, AppColors.subText)),
                        Text('${it.system} kg', style: ts(12, FontWeight.w600, AppColors.brownDark)),
                      ]),
                    ]),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(25, 8, 25, MediaQuery.of(context).padding.bottom + 16),
            child: TButton(
              'Review Hasil Opname',
              arrow: true,
              onTap: _done == 0
                  ? null
                  : () => Navigator.push(
                      context, MaterialPageRoute(builder: (_) => HasilOpnamePage(items: _items, review: true))),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================ SCAN QR BAHAN ============================
class ScanBahanPage extends StatelessWidget {
  final List<OpnameItem> items;
  const ScanBahanPage({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    // TODO FE: ganti dengan hasil scan kamera
    final it = items.firstWhere((e) => e.physical == null, orElse: () => items.first);
    const navy = Color(0xFF2F4A7A);
    return Scaffold(
      backgroundColor: navy,
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 20, bottom: 20, left: 20, right: 20),
            color: const Color(0xFF3A5A9B),
            child: Stack(alignment: Alignment.center, children: [
              Align(
                alignment: Alignment.centerLeft,
                child: InkWell(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.arrow_back, color: Colors.white),
                ),
              ),
              Text('Scan QR Bahan', style: ts(16, FontWeight.w600, Colors.white)),
            ]),
          ),
          Expanded(
            child: Center(
              child: Container(
                width: 260, height: 260,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.orange, width: 3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(child: Container(height: 2, width: 200, color: AppColors.orange)),
              ),
            ),
          ),
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(25, 16, 25, MediaQuery.of(context).padding.bottom + 16),
            decoration: const BoxDecoration(
              color: AppColors.cardWarnBg,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Bahan terdeteksi', style: ts(10, FontWeight.w400, AppColors.subText)),
              Text(it.name, style: ts(16, FontWeight.w600, AppColors.brownDark)),
              Text('Stok sistem: ${it.system} kg · ${it.category}', style: ts(11, FontWeight.w400, AppColors.subText)),
              const SizedBox(height: 14),
              TButton('Berikutnya', arrow: true, onTap: () async {
                await showDetailStockSheet(context, it);
                if (context.mounted) Navigator.pop(context);
              }),
            ]),
          ),
        ],
      ),
    );
  }
}

// ============================ SHEET DETAIL STOCK ============================
Future<void> showDetailStockSheet(BuildContext context, OpnameItem it) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (_) => _StockSheet(item: it),
  );
}

class _StockSheet extends StatefulWidget {
  final OpnameItem item;
  const _StockSheet({required this.item});

  @override
  State<_StockSheet> createState() => _StockSheetState();
}

class _StockSheetState extends State<_StockSheet> {
  late final TextEditingController _c =
      TextEditingController(text: widget.item.physical?.toString() ?? '');

  int? get _v => int.tryParse(_c.text);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final it = widget.item;
    final d = (_v ?? it.system) - it.system;
    final Color bg = d < 0 ? AppColors.ditolakBg : (d > 0 ? AppColors.disetujuiBg : AppColors.cardWarnBg);
    final Color fg = d < 0 ? AppColors.ditolakText : (d > 0 ? AppColors.disetujuiText : AppColors.subText);
    return Padding(
      padding: EdgeInsets.fromLTRB(
          20, 10, 20, MediaQuery.of(context).viewInsets.bottom + MediaQuery.of(context).padding.bottom + 20),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
            width: 40, height: 4,
            decoration: BoxDecoration(color: AppColors.sheetHandle, borderRadius: BorderRadius.circular(2))),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(child: Text('Detail Stock', style: ts(14, FontWeight.w600, AppColors.brownDark))),
          InkWell(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 28, height: 28,
              decoration: const BoxDecoration(color: AppColors.filterItemBg, shape: BoxShape.circle),
              child: const Icon(Icons.close, size: 16, color: AppColors.brown),
            ),
          ),
        ]),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: AppColors.cardWarnBg, borderRadius: BorderRadius.circular(8)),
          child: Row(children: [TItemTile(name: it.name, sub: it.category)]),
        ),
        const SizedBox(height: 12),
        Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Stok Sistem', style: ts(11, FontWeight.w500, AppColors.brownDark)),
              Text('${it.system} kg', style: ts(22, FontWeight.w700, AppColors.brownDark)),
            ]),
          ),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(child: Text('Jumlah Fisik', style: ts(11, FontWeight.w500, AppColors.brownDark))),
                Text('*Wajib', style: ts(9, FontWeight.w500, AppColors.red)),
              ]),
              const SizedBox(height: 4),
              Container(
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.primary)),
                child: Row(children: [
                  Expanded(
                    child: TextField(
                      controller: _c,
                      autofocus: true,
                      keyboardType: TextInputType.number,
                      onChanged: (_) => setState(() {}),
                      style: ts(14, FontWeight.w600, AppColors.brownDark),
                      decoration: const InputDecoration(isDense: true, border: InputBorder.none),
                    ),
                  ),
                  Text('kg', style: ts(11, FontWeight.w400, AppColors.subText)),
                ]),
              ),
            ]),
          ),
        ]),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
          child: Row(children: [
            Expanded(child: Text('Selisih', style: ts(12, FontWeight.w600, fg))),
            Text('${d > 0 ? '+' : ''}$d kg', style: ts(13, FontWeight.w700, fg)),
          ]),
        ),
        const SizedBox(height: 16),
        TButton('Simpan', onTap: _v == null ? null : () {
          it.physical = _v;
          Navigator.pop(context);
        }),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Kembali', style: ts(13, FontWeight.w500, AppColors.brownDark)),
        ),
      ]),
    );
  }
}
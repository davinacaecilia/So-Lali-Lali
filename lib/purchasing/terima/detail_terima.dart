import 'package:flutter/material.dart';

import '../partials/colors.dart';
import 'detail_nota.dart';
import 'konfirmasi_terima.dart';
import 'terima_common.dart';

// ============================ DETAIL TERIMA ============================
class DetailTerimaPage extends StatefulWidget {
  final TerimaPo po;
  const DetailTerimaPage({super.key, required this.po});

  @override
  State<DetailTerimaPage> createState() => _DetailTerimaPageState();
}

class _DetailTerimaPageState extends State<DetailTerimaPage> {
  List<TerimaItem> get _items => widget.po.items;
  int get _checked => _items.where((e) => e.checked).length;

  TerimaStatus get _status => _checked == 0
      ? TerimaStatus.menunggu
      : (_checked == _items.length ? TerimaStatus.selesai : TerimaStatus.sebagian);

  Future<void> _tapItem(TerimaItem it) async {
    if (it.checked) {
      showItemDetailSheet(context, it);
      return;
    }
    final ok = await Navigator.push<bool>(
        context, MaterialPageRoute(builder: (_) => InputItemPage(item: it)));
    if (ok == true) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          TerimaTopBar(title: 'Terima ${widget.po.code}'),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(25, 22, 25, 24),
              child: Column(
                children: [
                  _summaryCard(),
                  if (_checked > 0) ...[
                    const SizedBox(height: 12),
                    _detailRow(),
                  ],
                  const SizedBox(height: 18),
                  sectionTitle('Daftar Item'),
                  const SizedBox(height: 12),
                  for (final it in _items) ...[
                    _ItemRow(item: it, onTap: () => _tapItem(it)),
                    const SizedBox(height: 10),
                  ],
                  const SizedBox(height: 2),
                  const TWarnBox(
                      'Item yang belum dicek dianggap belum diterima, sehingga penerimaan dicatat sebagai sebagian.'),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(25, 8, 25, MediaQuery.of(context).padding.bottom + 16),
            child: TButton(
              'Konfirmasi Penerimaan',
              arrow: true,
              onTap: _checked == 0
                  ? null
                  : () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => KonfirmasiTerimaPage(po: widget.po))),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryCard() {
    final p = _checked / _items.length;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: cardDeco(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Expanded(child: Text(widget.po.supplier, style: ts(14, FontWeight.w600, AppColors.brown))),
            TBadge.status(_status),
          ]),
          Text(widget.po.summary, style: ts(11, FontWeight.w400, AppColors.subText)),
          const SizedBox(height: 12),
          Text('$_checked dari ${_items.length} item sudah dicek',
              style: ts(12, FontWeight.w500, AppColors.brownDark)),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: p,
              minHeight: 6,
              backgroundColor: AppColors.filterItemSelectedBg,
              valueColor: const AlwaysStoppedAnimation(AppColors.orange),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow() => Material(
        color: AppColors.cardWarnBg,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: () => Navigator.push(
              context, MaterialPageRoute(builder: (_) => const DetailNotaPage())),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.cardWarnBorder),
            ),
            child: Row(children: [
              Expanded(child: Text('Lihat Detail Penerimaan', style: ts(12, FontWeight.w500, AppColors.brown))),
              const Icon(Icons.chevron_right, size: 18, color: AppColors.brown),
            ]),
          ),
        ),
      );
}

class _ItemRow extends StatelessWidget {
  final TerimaItem item;
  final VoidCallback onTap;
  const _ItemRow({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: cardDeco(),
            child: Row(children: [
              Expanded(child: TItemTile(name: item.name, sub: 'Dipesan ${item.ordered}kg')),
              item.checked
                  ? TBadge('Diterima ${item.received}kg', AppColors.disetujuiBg, AppColors.disetujuiText)
                  : const TBadge('Belum Dicek', AppColors.ditolakBg, AppColors.ditolakText),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right, size: 18, color: AppColors.subText),
            ]),
          ),
        ),
      );
}

// ============================ SHEET DETAIL ITEM ============================
void showItemDetailSheet(BuildContext context, TerimaItem it) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (_) => Padding(
      padding: EdgeInsets.fromLTRB(20, 10, 20, MediaQuery.of(context).padding.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              width: 40, height: 4,
              decoration: BoxDecoration(color: AppColors.sheetHandle, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(child: Text('Detail Item', style: ts(14, FontWeight.w600, AppColors.brownDark))),
            InkWell(
              onTap: () => Navigator.pop(context),
              customBorder: const CircleBorder(),
              child: Container(
                width: 28, height: 28,
                decoration: const BoxDecoration(color: AppColors.filterItemBg, shape: BoxShape.circle),
                child: const Icon(Icons.close, size: 16, color: AppColors.brown),
              ),
            ),
          ]),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppColors.cardWarnBg, borderRadius: BorderRadius.circular(8)),
            child: Row(children: [TItemTile(name: it.name, sub: 'Dipesan ${it.ordered}kg')]),
          ),
          const SizedBox(height: 12),
          _kv('Jumlah Diterima', '${it.received} kg', bold: true),
          _kv('Tanggal Kadaluwarsa', it.expiry == null ? '-' : fmtDate(it.expiry!), bold: true),
          _kv('Catatan', it.note.isEmpty ? '-' : it.note),
        ],
      ),
    ),
  );
}

Widget _kv(String k, String v, {bool bold = false}) => Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.divider))),
      child: Row(children: [
        Expanded(child: Text(k, style: ts(11, FontWeight.w400, AppColors.brown))),
        Text(v, style: ts(11, bold ? FontWeight.w600 : FontWeight.w400, AppColors.brownDark)),
      ]),
    );

// ============================ INPUT ITEM ============================
class InputItemPage extends StatefulWidget {
  final TerimaItem item;
  const InputItemPage({super.key, required this.item});

  @override
  State<InputItemPage> createState() => _InputItemPageState();
}

class _InputItemPageState extends State<InputItemPage> {
  late final TextEditingController _qty = TextEditingController(text: '${widget.item.ordered}');
  final _note = TextEditingController();
  DateTime _date = DateTime.now().add(const Duration(days: 180));

  @override
  void dispose() {
    _qty.dispose();
    _note.dispose();
    super.dispose();
  }

  void _step(int d) {
    final v = ((int.tryParse(_qty.text) ?? 0) + d).clamp(0, 9999);
    setState(() => _qty.text = '$v');
  }

  Future<void> _pickDate() async {
    final r = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
      builder: (c, child) => Theme(
        data: Theme.of(c).copyWith(
          colorScheme: ColorScheme.light(
            primary: const Color(0xFFE59E2C),
            onPrimary: Colors.white,
            surface: Colors.white,
            onSurface: AppColors.brownDark,
          ),
        ),
        child: child!,
      ),
    );
    if (r != null) setState(() => _date = r);
  }

  void _save() {
    widget.item
      ..received = int.tryParse(_qty.text) ?? 0
      ..expiry = _date
      ..note = _note.text;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const TerimaTopBar(title: 'Input Item'),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    color: AppColors.cardWarnBg,
                    padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                    child: TItemTile(name: widget.item.name, sub: 'Dipesan ${widget.item.ordered}kg'),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(25, 18, 25, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label('Jumlah Diterima', required: true),
                        Row(children: [
                          _StepBtn('-', () => _step(-1)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Container(
                              height: 44,
                              decoration: cardDeco(),
                              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                                IntrinsicWidth(
                                  child: TextField(
                                    controller: _qty,
                                    textAlign: TextAlign.center,
                                    keyboardType: TextInputType.number,
                                    style: ts(16, FontWeight.w600, AppColors.brownDark),
                                    decoration: const InputDecoration(
                                        isDense: true, border: InputBorder.none, constraints: BoxConstraints(minWidth: 24)),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text('kg', style: ts(11, FontWeight.w400, AppColors.subText)),
                              ]),
                            ),
                          ),
                          const SizedBox(width: 8),
                          _StepBtn('+', () => _step(1)),
                        ]),
                        const SizedBox(height: 16),
                        _label('Tanggal Kadaluwarsa', required: true),
                        InkWell(
                          onTap: _pickDate,
                          child: Container(
                            height: 44,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: cardDeco(),
                            child: Row(children: [
                              const Icon(Icons.calendar_today_outlined, size: 16, color: AppColors.brown),
                              const SizedBox(width: 8),
                              Expanded(
                                  child: Text(
                                      '${_date.day.toString().padLeft(2, '0')}/${_date.month.toString().padLeft(2, '0')}/${_date.year}',
                                      style: ts(12, FontWeight.w400, AppColors.brownDark))),
                              const Icon(Icons.keyboard_arrow_down, size: 20, color: AppColors.brown),
                            ]),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const TWarnBox(
                            'Tanggal kadaluwarsa secara otomatis dibuat sesuai Batas Kadaluwarsa 180 hari yang sudah dibuat sebelumnya.\n\nJika tanggal tidak sesuai silahkan atur tanggal secara manual.'),
                        const SizedBox(height: 16),
                        _label('Catatan', optional: true),
                        Container(
                          decoration: cardDeco(),
                          child: TextField(
                            controller: _note,
                            maxLines: 4,
                            style: ts(12, FontWeight.w400, AppColors.brownDark),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.all(12),
                              hintText: 'Contoh: Kemasan sedikit penyok.',
                              hintStyle: ts(12, FontWeight.w400, AppColors.subText.withOpacity(0.6)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(25, 8, 25, MediaQuery.of(context).padding.bottom + 16),
            child: TButton('Simpan Item', onTap: _save),
          ),
        ],
      ),
    );
  }

  Widget _label(String t, {bool required = false, bool optional = false}) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(children: [
          Expanded(child: Text(t, style: ts(12, FontWeight.w600, AppColors.brownDark))),
          if (required) Text('*Wajib', style: ts(10, FontWeight.w500, AppColors.red)),
          if (optional) Text('Opsional', style: ts(10, FontWeight.w400, AppColors.subText)),
        ]),
      );
}

class _StepBtn extends StatelessWidget {
  final String s;
  final VoidCallback onTap;
  const _StepBtn(this.s, this.onTap);

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 44, height: 44,
          alignment: Alignment.center,
          decoration: cardDeco(),
          child: Text(s, style: ts(18, FontWeight.w600, AppColors.brown)),
        ),
      );
}
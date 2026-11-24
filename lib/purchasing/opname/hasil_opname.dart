import 'package:flutter/material.dart';

import '../dashboard.dart';
import '../partials/colors.dart';
import '../terima/terima_common.dart';
import 'opname_page.dart';

// ============================ DETAIL / REVIEW HASIL ============================
/// [review] true  = Review Hasil Opname (ada tombol Kirim).
/// [review] false = Detail Hasil Opname ([waiting] menampilkan info menunggu Owner).
class HasilOpnamePage extends StatefulWidget {
  final List<OpnameItem>? items;
  final bool review;
  final bool waiting;
  const HasilOpnamePage({super.key, this.items, this.review = false, this.waiting = false});

  @override
  State<HasilOpnamePage> createState() => _HasilOpnamePageState();
}

class _HasilOpnamePageState extends State<HasilOpnamePage> {
  late final List<OpnameItem> _items = widget.items ??
      (dummyOpnameItems()
        ..[0].physical = 14
        ..[1].physical = 10
        ..[2].physical = 34
        ..[3].physical = 8);
  bool _kurang = true;

  Future<void> _kirim() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 76, height: 76,
              decoration: BoxDecoration(
                  color: AppColors.iconTile, borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.help_outline_rounded, color: AppColors.orange, size: 34),
            ),
            const SizedBox(height: 18),
            Text.rich(
              TextSpan(
                style: ts(16, FontWeight.w600, AppColors.brownDark, h: 1.4),
                children: [
                  const TextSpan(text: 'Kirim Hasil '),
                  TextSpan(
                      text: 'Opname Mingguan\n(16 Nov – 22 Nov)',
                      style: ts(16, FontWeight.w600, AppColors.orange, h: 1.4)),
                  const TextSpan(text: '?'),
                ],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 14),
            Text('Tindakan ini tidak dapat\ndiulang kembali',
                textAlign: TextAlign.center,
                style: ts(14, FontWeight.w400, AppColors.subText, h: 1.4)),
            const SizedBox(height: 24),
            Row(children: [
              Expanded(child: _DlgBtn('Batal', false, () => Navigator.pop(context, false))),
              const SizedBox(width: 12),
              Expanded(child: _DlgBtn('Kirim', true, () => Navigator.pop(context, true))),
            ]),
          ]),
        ),
      ),
    );
    // TODO FE: kirim ke API
    if (ok == true && mounted) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const OpnameBerhasilPage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final sesuai = _items.where((e) => e.physical != null && e.diff == 0).length;
    final selisih = _items.where((e) => e.physical != null && e.diff != 0).length;
    final rows = _items.where((e) => e.physical != null && (_kurang ? e.diff < 0 : e.diff > 0)).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          TerimaTopBar(title: widget.review ? 'Review Hasil Opname' : 'Detail Hasil Opname'),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(25, 20, 25, 24),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: cardDeco(),
                  child: Row(children: [
                    Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(color: AppColors.iconTile, borderRadius: BorderRadius.circular(8)),
                      child: const Icon(Icons.assignment_outlined, color: AppColors.iconBrown, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Opname Mingguan', style: ts(13, FontWeight.w600, AppColors.brownDark)),
                      Text('9 Nov - 22 Nov', style: ts(10, FontWeight.w400, AppColors.subText)),
                      Text('${_items.length} bahan', style: ts(10, FontWeight.w400, AppColors.subText)),
                    ]),
                  ]),
                ),
                if (widget.waiting) ...[
                  const SizedBox(height: 12),
                  const TWarnBox('Hasil Opname ini sedang menunggu persetujuan dari Owner.'),
                ],
                const SizedBox(height: 14),
                Row(children: [
                  Expanded(child: _Stat('Sesuai', sesuai, AppColors.disetujuiBg, AppColors.disetujuiText)),
                  const SizedBox(width: 12),
                  Expanded(child: _Stat('Selisih', selisih, AppColors.ditolakBg, AppColors.ditolakText)),
                ]),
                const SizedBox(height: 18),
                Text('Detail Selisih', style: ts(15, FontWeight.w600, AppColors.brown)),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(color: AppColors.diprosesBg, borderRadius: BorderRadius.circular(8)),
                  child: Row(children: [
                    _Seg('Kurang', _kurang, () => setState(() => _kurang = true)),
                    _Seg('Berlebih', !_kurang, () => setState(() => _kurang = false)),
                  ]),
                ),
                const SizedBox(height: 6),
                if (rows.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Center(child: Text('Tidak ada data', style: ts(11, FontWeight.w400, AppColors.subText))),
                  ),
                for (final r in rows)
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.divider))),
                    child: Row(children: [
                      Expanded(child: Text(r.name, style: ts(12, FontWeight.w500, AppColors.brownDark))),
                      Text('${r.diff > 0 ? '+' : ''}${r.diff} kg',
                          style: ts(12, FontWeight.w600,
                              r.diff < 0 ? AppColors.ditolakText : AppColors.disetujuiText)),
                    ]),
                  ),
              ]),
            ),
          ),
          if (widget.review)
            Padding(
              padding: EdgeInsets.fromLTRB(25, 8, 25, MediaQuery.of(context).padding.bottom + 16),
              child: TButton('Kirim Hasil Opname', onTap: _kirim),
            ),
        ],
      ),
    );
  }
}

class _DlgBtn extends StatelessWidget {
  final String label;
  final bool filled;
  final VoidCallback onTap;
  const _DlgBtn(this.label, this.filled, this.onTap);

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: filled ? AppColors.orange : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: filled ? null : Border.all(color: AppColors.brownDark),
          ),
          child: Text(label,
              style: ts(14, FontWeight.w600, filled ? Colors.white : AppColors.brownDark)),
        ),
      );
}

class _Stat extends StatelessWidget {
  final String label;
  final int value;
  final Color bg, fg;
  const _Stat(this.label, this.value, this.bg, this.fg);

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: ts(12, FontWeight.w500, fg)),
          Text('$value', style: ts(24, FontWeight.w700, fg)),
        ]),
      );
}

class _Seg extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _Seg(this.label, this.active, this.onTap);

  @override
  Widget build(BuildContext context) => Expanded(
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: active ? AppColors.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(label, style: ts(12, FontWeight.w600, active ? Colors.white : AppColors.primary)),
          ),
        ),
      );
}

// ============================ BERHASIL ============================
class OpnameBerhasilPage extends StatelessWidget {
  const OpnameBerhasilPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(25, 40, 25, 24),
          child: Column(children: [
            Expanded(
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Container(
                  width: 110, height: 110,
                  decoration: const BoxDecoration(color: AppColors.iconTile, shape: BoxShape.circle),
                  child: Center(
                    child: Container(
                      width: 80, height: 80,
                      decoration: const BoxDecoration(color: AppColors.orange, shape: BoxShape.circle),
                      child: const Icon(Icons.check, color: Colors.white, size: 48),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text('Hasil Opname\nDikirimkan',
                    textAlign: TextAlign.center, style: ts(22, FontWeight.w600, AppColors.sectionTitle, h: 1.25)),
                const SizedBox(height: 6),
                Text('Hasil Opname akan ditinjau oleh Owner.\nSelisih, jika ada, akan disesuaikan.',
                    textAlign: TextAlign.center, style: ts(11, FontWeight.w400, AppColors.subText)),
              ]),
            ),
            TButton('Lihat Detail Opname',
                onTap: () => Navigator.push(
                    context, MaterialPageRoute(builder: (_) => const HasilOpnamePage(waiting: true)))),
            const SizedBox(height: 10),
            TButton('Kembali Beranda',
                outlined: true,
                onTap: () => Navigator.pushAndRemoveUntil(
                    context, MaterialPageRoute(builder: (_) => const DashboardPurchasing()), (r) => false)),
          ]),
        ),
      ),
    );
  }
}
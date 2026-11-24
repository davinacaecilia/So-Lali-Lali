import 'package:flutter/material.dart';

import '../kasir/kasir_theme.dart';
import '../kasir/kasir_widgets.dart';
import 'kitchen_model.dart';
import 'kitchen_widgets.dart';

/// Popup "Detail Stock": isi jumlah fisik, lihat selisih.
/// Mengembalikan jumlah fisik (double) kalau disimpan, null kalau dibatalkan.
Future<double?> showDetailStockSheet(
  BuildContext context, {
  required BahanStok bahan,
  double? awal,
}) {
  return showKSheet<double>(
    context,
    (_) => _DetailStockSheet(bahan: bahan, awal: awal),
  );
}

class _DetailStockSheet extends StatefulWidget {
  final BahanStok bahan;
  final double? awal;
  const _DetailStockSheet({required this.bahan, this.awal});

  @override
  State<_DetailStockSheet> createState() => _DetailStockSheetState();
}

class _DetailStockSheetState extends State<_DetailStockSheet> {
  late final _ctrl =
      TextEditingController(text: widget.awal == null ? '' : fmtQty(widget.awal!));

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  double? get _fisik {
    final v = parseQty(_ctrl.text);
    return (v == null || v < 0) ? null : v;
  }

  @override
  Widget build(BuildContext context) {
    final b = widget.bahan;
    final fisik = _fisik;
    final selisih = fisik == null ? null : fisik - b.total;
    const coklat = Color(0xFFA8651B);

    final Color selisihBg;
    final Color selisihFg;
    if (selisih == null) {
      selisihBg = KColors.sand;
      selisihFg = KColors.muted;
    } else if (selisih < 0) {
      selisihBg = KColors.redBg;
      selisihFg = KColors.red;
    } else {
      selisihBg = KColors.greenBg;
      selisihFg = KColors.green;
    }

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              sheetHandle(),
              Padding(
                padding: const EdgeInsets.fromLTRB(23, 20, 23, 14),
                child: Row(
                  children: [
                    Expanded(child: Text('Detail Stock', style: ks(18, w: FontWeight.w700))),
                    const SheetCloseButton(),
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: KColors.creamField,
                  border: Border.symmetric(horizontal: BorderSide(color: KColors.border)),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 23, vertical: 12),
                child: Row(
                  children: [
                    BahanIcon(b.ikon, size: 44, bg: KColors.sand),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(b.nama, style: ks(15, w: FontWeight.w700)),
                          Text(b.kategori, style: ks(12, c: KColors.brown)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(23, 16, 23, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Text('Stok Sistem', style: ks(13, w: FontWeight.w700)),
                              ),
                              Container(
                                height: 56,
                                alignment: Alignment.centerLeft,
                                padding: const EdgeInsets.symmetric(horizontal: 14),
                                decoration: BoxDecoration(
                                  color: KColors.creamField,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: KColors.border),
                                ),
                                child: Text.rich(
                                  TextSpan(
                                    text: fmtQty(b.total),
                                    style: ks(24, w: FontWeight.w800, c: coklat),
                                    children: [
                                      TextSpan(
                                        text: ' ${satuanPendek(b.satuan)}',
                                        style: ks(14, w: FontWeight.w700, c: coklat),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const FieldLabel('Jumlah Fisik'),
                              Container(
                                height: 56,
                                padding: const EdgeInsets.symmetric(horizontal: 14),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: KColors.brown, width: 0.8),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller: _ctrl,
                                        autofocus: true,
                                        onChanged: (_) => setState(() {}),
                                        keyboardType: const TextInputType.numberWithOptions(
                                            decimal: true),
                                        style: ks(15, w: FontWeight.w500),
                                        decoration: InputDecoration(
                                          isCollapsed: true,
                                          border: InputBorder.none,
                                          hintText: '0',
                                          hintStyle: ks(15, c: KColors.muted),
                                        ),
                                      ),
                                    ),
                                    Text(satuanPendek(b.satuan),
                                        style: ks(13, c: KColors.brown)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: selisihBg,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Text('Selisih', style: ks(14, w: FontWeight.w700)),
                          const Spacer(),
                          Text(
                            selisih == null ? '-' : fmtSelisih(selisih, b.satuan),
                            style: ks(16, w: FontWeight.w800, c: selisihFg),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 26),
                    KButton(
                      label: 'Simpan',
                      onPressed: fisik == null ? null : () => Navigator.pop(context, fisik),
                    ),
                    Center(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Kembali',
                            style: ks(13, w: FontWeight.w600, c: KColors.navyDark)),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

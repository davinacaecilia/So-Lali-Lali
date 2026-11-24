import 'package:flutter/material.dart';

import '../kasir/kasir_theme.dart';
import '../kasir/kasir_widgets.dart';
import 'kitchen_model.dart';
import 'kitchen_widgets.dart';

/// Popup "Pilih Bahan" (2 langkah): pilih bahan -> isi jumlah request.
/// Mengembalikan [RestockItem], atau null kalau dibatalkan.
Future<RestockItem?> showPilihBahanSheet(
  BuildContext context, {
  required Set<String> sudahDipilih,
  BahanStok? bahanAwal,
}) {
  return showKSheet<RestockItem>(
    context,
    (_) => _PilihBahanSheet(sudahDipilih: sudahDipilih, bahanAwal: bahanAwal),
  );
}

class _PilihBahanSheet extends StatefulWidget {
  final Set<String> sudahDipilih;
  final BahanStok? bahanAwal; // ← tambah
  const _PilihBahanSheet({required this.sudahDipilih, this.bahanAwal});

  @override
  State<_PilihBahanSheet> createState() => _PilihBahanSheetState();
}

class _PilihBahanSheetState extends State<_PilihBahanSheet> {
  final _jumlah = TextEditingController();
  String _query = '';
  late BahanStok? _dipilih = widget.bahanAwal;

  @override
  void dispose() {
    _jumlah.dispose();
    super.dispose();
  }

  double? get _angka {
    final v = parseQty(_jumlah.text);
    return (v == null || v <= 0) ? null : v;
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.88,
          ),
          child: _dipilih == null ? _langkahPilih() : _langkahJumlah(_dipilih!),
        ),
      ),
    );
  }

  Widget _header() => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      sheetHandle(),
      Padding(
        padding: const EdgeInsets.fromLTRB(23, 20, 23, 14),
        child: Row(
          children: [
            Expanded(
              child: Text('Pilih Bahan', style: ks(18, w: FontWeight.w700)),
            ),
            const SheetCloseButton(),
          ],
        ),
      ),
      const Divider(height: 1, color: KColors.sand),
    ],
  );

  // ---- Langkah 1: daftar bahan ----
  Widget _langkahPilih() {
    final list = KitchenStore.instance.bahan
        .where((b) => b.nama.toLowerCase().contains(_query.toLowerCase()))
        .toList();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _header(),
        Padding(
          padding: const EdgeInsets.fromLTRB(23, 16, 23, 10),
          child: KSearchField(
            hint: 'Cari nama bahan',
            onChanged: (v) => setState(() => _query = v),
          ),
        ),
        Flexible(
          child: ListView.builder(
            shrinkWrap: true,
            padding: const EdgeInsets.only(bottom: 16),
            itemCount: list.length,
            itemBuilder: (context, i) {
              final b = list[i];
              final sudah = widget.sudahDipilih.contains(b.id);
              return Opacity(
                opacity: sudah ? 0.5 : 1,
                child: InkWell(
                  onTap: sudah ? null : () => setState(() => _dipilih = b),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 23,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        BahanIcon(b.ikon, size: 44, bg: KColors.sand),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                b.nama,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: ks(
                                  15,
                                  w: FontWeight.w700,
                                  c: KColors.brownDark,
                                ),
                              ),
                              Text(
                                '${b.kategori} · ${b.satuan}',
                                style: ks(12, c: KColors.brown),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (sudah)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: KColors.sand,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Sudah dalam daftar',
                              style: ks(
                                10,
                                w: FontWeight.w500,
                                c: KColors.muted,
                              ),
                            ),
                          )
                        else
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              StokBadge(status: b.status),
                              const SizedBox(height: 2),
                              Text(
                                '${fmtQty(b.total)} ${b.satuan}',
                                style: ks(14, w: FontWeight.w700),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ---- Langkah 2: isi jumlah ----
  Widget _langkahJumlah(BahanStok b) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _header(),
        Container(
          width: double.infinity,
          color: KColors.creamField,
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
              Text('Request Restock', style: ks(13, w: FontWeight.w700)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: KNumberField(
                      controller: _jumlah,
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  const SizedBox(width: 12),
                  KUnitBox(b.satuan),
                ],
              ),
              const SizedBox(height: 26),
              KButton(
                label: 'Tambahkan ke Daftar',
                onPressed: _angka == null
                    ? null
                    : () => Navigator.pop(context, RestockItem(b, _angka!)),
              ),
              Center(
                child: TextButton(
                  onPressed: () => setState(() {
                    _dipilih = null;
                    _jumlah.clear();
                  }),
                  child: Text(
                    'Kembali',
                    style: ks(13, w: FontWeight.w600, c: KColors.navyDark),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ],
    );
  }
}

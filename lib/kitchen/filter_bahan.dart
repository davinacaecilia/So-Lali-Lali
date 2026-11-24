import 'package:flutter/material.dart';

import '../kasir/kasir_theme.dart';
import 'kitchen_model.dart';
import 'kitchen_widgets.dart';

enum UrutBahan { nama, stokTersedikit, kedaluwarsa }

class BahanFilter {
  final String? kategori; // null = semua
  final StokStatus? status; // null = semua
  final UrutBahan urut;
  const BahanFilter({this.kategori, this.status, this.urut = UrutBahan.nama});

  bool cocok(BahanStok b) {
    if (kategori != null && b.kategori != kategori) return false;
    if (status != null && b.status != status) return false;
    return true;
  }

  List<BahanStok> terapkan(List<BahanStok> semua) {
    final list = semua.where(cocok).toList();
    switch (urut) {
      case UrutBahan.nama:
        list.sort((a, b) => a.nama.toLowerCase().compareTo(b.nama.toLowerCase()));
      case UrutBahan.stokTersedikit:
        list.sort((a, b) => a.total.compareTo(b.total));
      case UrutBahan.kedaluwarsa:
        list.sort((a, b) =>
            (a.sisaHariTerdekat ?? 99999).compareTo(b.sisaHariTerdekat ?? 99999));
    }
    return list;
  }
}

Future<BahanFilter?> showFilterBahanSheet(BuildContext context, BahanFilter current) {
  return showKSheet<BahanFilter>(context, (_) => _FilterBahanSheet(initial: current));
}

class _FilterBahanSheet extends StatefulWidget {
  final BahanFilter initial;
  const _FilterBahanSheet({required this.initial});

  @override
  State<_FilterBahanSheet> createState() => _FilterBahanSheetState();
}

class _FilterBahanSheetState extends State<_FilterBahanSheet> {
  late String? _kategori = widget.initial.kategori;
  late StokStatus? _status = widget.initial.status;
  late UrutBahan _urut = widget.initial.urut;

  static const _urutLabel = {
    UrutBahan.nama: 'Nama (A-Z)',
    UrutBahan.stokTersedikit: 'Stok Tersedikit',
    UrutBahan.kedaluwarsa: 'Paling Cepat Kedaluwarsa',
  };

  @override
  Widget build(BuildContext context) {
    final store = KitchenStore.instance;
    return FilterSheetFrame(
      title: 'Filter Bahan',
      subtitle: 'Pilih kategori dan status stok bahan dapur',
      onReset: () => setState(() {
        _kategori = null;
        _status = null;
        _urut = UrutBahan.nama;
      }),
      onApply: () => Navigator.pop(
        context,
        BahanFilter(kategori: _kategori, status: _status, urut: _urut),
      ),
      children: [
        FilterRadioTile(
          label: 'Semua Kategori',
          count: '${store.countKategori(null)} bahan',
          selected: _kategori == null,
          onTap: () => setState(() => _kategori = null),
        ),
        for (final k in kKategoriBahan)
          FilterRadioTile(
            label: k,
            count: '${store.countKategori(k)} bahan',
            selected: _kategori == k,
            onTap: () => setState(() => _kategori = k),
          ),
        const FilterSectionLabel('Status Ketersediaan Stok'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 23),
          child: Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              FilterChipOption(
                label: 'Semua',
                solid: true,
                selected: _status == null,
                onTap: () => setState(() => _status = null),
              ),
              FilterChipOption(
                label: 'Aman',
                bg: KColors.greenBg,
                fg: KColors.green,
                dot: KColors.green,
                selected: _status == StokStatus.aman,
                onTap: () => setState(() => _status = StokStatus.aman),
              ),
              FilterChipOption(
                label: 'Menipis',
                bg: KColors.peach,
                fg: KColors.rust,
                dot: KColors.rust,
                selected: _status == StokStatus.menipis,
                onTap: () => setState(() => _status = StokStatus.menipis),
              ),
              FilterChipOption(
                label: 'Habis',
                bg: KColors.redBg,
                fg: KColors.red,
                dot: KColors.red,
                selected: _status == StokStatus.habis,
                onTap: () => setState(() => _status = StokStatus.habis),
              ),
            ],
          ),
        ),
        const FilterSectionLabel('Urutkan Berdasarkan'),
        SizedBox(
          height: 38,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 23),
            children: [
              for (final u in UrutBahan.values)
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: FilterChipOption(
                    label: _urutLabel[u]!,
                    solid: true,
                    selected: _urut == u,
                    onTap: () => setState(() => _urut = u),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

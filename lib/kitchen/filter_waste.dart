import 'package:flutter/material.dart';

import '../kasir/kasir_theme.dart';
import 'kitchen_model.dart';
import 'kitchen_widgets.dart';

class WasteFilter {
  final String? kategori; // kategori bahan, null = semua
  final DateTimeRange? periode; // null = semua tanggal
  final String? keterangan; // Rusak | Tumpah | Expired, null = semua
  const WasteFilter({this.kategori, this.periode, this.keterangan});

  bool cocok(WasteRecord w) {
    if (kategori != null && w.bahan.kategori != kategori) return false;
    if (keterangan != null && w.keterangan != keterangan) return false;
    if (periode != null) {
      final p = periode!;
      final mulai = DateTime(p.start.year, p.start.month, p.start.day);
      final akhir = DateTime(p.end.year, p.end.month, p.end.day).add(const Duration(days: 1));
      if (w.waktu.isBefore(mulai) || !w.waktu.isBefore(akhir)) return false;
    }
    return true;
  }
}

Future<WasteFilter?> showFilterWasteSheet(BuildContext context, WasteFilter current) {
  return showKSheet<WasteFilter>(context, (_) => _Sheet(initial: current));
}

class _Sheet extends StatefulWidget {
  final WasteFilter initial;
  const _Sheet({required this.initial});

  @override
  State<_Sheet> createState() => _SheetState();
}

class _SheetState extends State<_Sheet> {
  late String? _kategori = widget.initial.kategori;
  late DateTimeRange? _periode = widget.initial.periode;
  late String? _ket = widget.initial.keterangan;

  Future<void> _pilihTanggal() async {
    final now = DateTime.now();
    final res = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 1),
      initialDateRange: _periode,
    );
    if (res != null) setState(() => _periode = res);
  }

  @override
  Widget build(BuildContext context) {
    final store = KitchenStore.instance;
    final teks = _periode == null
        ? 'Pilih Tanggal'
        : '${formatTanggalPanjang(_periode!.start)} - ${formatTanggalPanjang(_periode!.end)}';

    return FilterSheetFrame(
      title: 'Filter Waste',
      subtitle: 'Pilih kategori bahan dan jenis waste',
      onReset: () => setState(() {
        _kategori = null;
        _periode = null;
        _ket = null;
      }),
      onApply: () => Navigator.pop(
        context,
        WasteFilter(kategori: _kategori, periode: _periode, keterangan: _ket),
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
        const FilterSectionLabel('Waktu'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 23),
          child: KDropdownField(
            height: 48,
            text: teks,
            isPlaceholder: _periode == null,
            onTap: _pilihTanggal,
            leading: const Icon(Icons.calendar_today_outlined, size: 18, color: KColors.ink),
          ),
        ),
        const FilterSectionLabel('Keterangan Waste'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 23),
          child: Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              FilterChipOption(
                label: 'Semua',
                solid: true,
                selected: _ket == null,
                onTap: () => setState(() => _ket = null),
              ),
              for (final k in const ['Rusak', 'Tumpah', 'Expired'])
                FilterChipOption(
                  label: k,
                  bg: statusColors(k).$1,
                  fg: statusColors(k).$2,
                  selected: _ket == k,
                  onTap: () => setState(() => _ket = k),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

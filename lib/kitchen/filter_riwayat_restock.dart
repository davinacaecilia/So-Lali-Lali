import 'package:flutter/material.dart';

import '../kasir/kasir_theme.dart';
import 'kitchen_model.dart';
import 'kitchen_widgets.dart';

class RestockFilter {
  final DateTimeRange? periode; // null = semua tanggal
  final Set<RestockStatus> status; // kosong = semua status
  const RestockFilter({this.periode, this.status = const {}});

  bool cocok(RestockRequest r) {
    if (status.isNotEmpty && !status.contains(r.status)) return false;
    if (periode != null) {
      final p = periode!;
      final mulai = DateTime(p.start.year, p.start.month, p.start.day);
      final akhir = DateTime(p.end.year, p.end.month, p.end.day).add(const Duration(days: 1));
      if (r.waktu.isBefore(mulai) || !r.waktu.isBefore(akhir)) return false;
    }
    return true;
  }
}

Future<RestockFilter?> showFilterRiwayatRestockSheet(
  BuildContext context,
  RestockFilter current,
) {
  return showKSheet<RestockFilter>(context, (_) => _Sheet(initial: current));
}

class _Sheet extends StatefulWidget {
  final RestockFilter initial;
  const _Sheet({required this.initial});

  @override
  State<_Sheet> createState() => _SheetState();
}

class _SheetState extends State<_Sheet> {
  late DateTimeRange? _periode = widget.initial.periode;
  late final Set<RestockStatus> _status = {...widget.initial.status};

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
    final teks = _periode == null
        ? 'Pilih Rentang Tanggal'
        : '${formatTanggalPanjang(_periode!.start)} - ${formatTanggalPanjang(_periode!.end)}';

    return FilterSheetFrame(
      title: 'Filter Riwayat Request',
      subtitle: 'Pilih kategori untuk menyaring riwayat request',
      onReset: () => setState(() {
        _periode = null;
        _status.clear();
      }),
      onApply: () =>
          Navigator.pop(context, RestockFilter(periode: _periode, status: {..._status})),
      children: [
        const FilterSectionLabel('Periode'),
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
        const FilterSectionLabel('Status Request'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 23),
          child: Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final s in _tampil)
                FilterChipOption(
                  label: s.label,
                  bg: statusColors(s.label).$1,
                  fg: statusColors(s.label).$2,
                  selected: _status.contains(s),
                  onTap: () => setState(
                    () => _status.contains(s) ? _status.remove(s) : _status.add(s),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  // Urutan tampil seperti desain: Selesai, Diproses, Menunggu, Ditolak.
  static const _tampil = [
    RestockStatus.selesai,
    RestockStatus.diproses,
    RestockStatus.menunggu,
    RestockStatus.ditolak,
  ];
}

import 'package:flutter/material.dart';

import 'kasir_model.dart';
import 'kasir_theme.dart';

/// Hasil filter Riwayat.
class RiwayatFilter {
  final DateTimeRange? periode; // null = semua tanggal
  const RiwayatFilter({this.periode});

  bool get aktif => periode != null;

  bool cocok(Transaksi t) {
    if (periode != null) {
      final mulai = DateTime(periode!.start.year, periode!.start.month, periode!.start.day);
      final akhir = DateTime(periode!.end.year, periode!.end.month, periode!.end.day)
          .add(const Duration(days: 1));
      if (t.waktu.isBefore(mulai) || !t.waktu.isBefore(akhir)) return false;
    }
    return true;
  }
}

Future<RiwayatFilter?> showRiwayatFilterSheet(
  BuildContext context,
  RiwayatFilter current,
) {
  return showModalBottomSheet<RiwayatFilter>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => _RiwayatFilterSheet(initial: current),
  );
}

class _RiwayatFilterSheet extends StatefulWidget {
  final RiwayatFilter initial;
  const _RiwayatFilterSheet({required this.initial});

  @override
  State<_RiwayatFilterSheet> createState() => _RiwayatFilterSheetState();
}

class _RiwayatFilterSheetState extends State<_RiwayatFilterSheet> {
  late DateTimeRange? _periode = widget.initial.periode;

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
    final teksPeriode = _periode == null
        ? 'Pilih Rentang Tanggal'
        : '${formatTanggal(_periode!.start)} - ${formatTanggal(_periode!.end)}';

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: X di kiri, judul di tengah
            Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close, size: 24, color: KColors.ink),
                ),
                Expanded(
                  child: Text(
                    'Filter Riwayat',
                    textAlign: TextAlign.center,
                    style: ks(17, w: FontWeight.w700, c: KColors.navy),
                  ),
                ),
                const SizedBox(width: 24),
              ],
            ),
            const SizedBox(height: 26),
            Text('Periode', style: ks(18, w: FontWeight.w700, c: KColors.navy)),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pilihTanggal,
              child: Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: KColors.sand),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined, size: 18, color: KColors.ink),
                    const SizedBox(width: 12),
                    Expanded(child: Text(teksPeriode, style: ks(13, w: FontWeight.w500))),
                    const Icon(Icons.keyboard_arrow_down, size: 24, color: KColors.ink),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            // Tombol Terapkan (gradient amber)
            GestureDetector(
              onTap: () => Navigator.pop(
                context,
                RiwayatFilter(periode: _periode),
              ),
              child: Container(
                height: 54,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFFF0B45E), KColors.amber],
                  ),
                ),
                child: Text('Terapkan Filter',
                    style: ks(17, w: FontWeight.w700, c: KColors.navyDark)),
              ),
            ),
            const SizedBox(height: 10),
            // Tombol Reset (outline)
            SizedBox(
              height: 54,
              child: OutlinedButton(
                onPressed: () => setState(() {
                  _periode = null;
                }),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: KColors.navyDark),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Center(
                  child: Text('Reset', style: ks(17, w: FontWeight.w700, c: KColors.navyDark)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

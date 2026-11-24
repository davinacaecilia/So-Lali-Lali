import 'package:flutter/material.dart';

import '../partials/colors.dart';
import 'terima_common.dart';

// ============================ DATA (DUMMY) ============================
class _NotaLine {
  final String name, exp, qty;
  final String? shortage; // null = sesuai
  const _NotaLine(this.name, this.exp, this.qty, [this.shortage]);
}

class _Nota {
  final String title;
  final List<_NotaLine> lines;
  const _Nota(this.title, this.lines);
}

const _dummyNota = [
  _Nota('Penerimaan 01', [
    _NotaLine('Biji Kopi Arabika', 'Exp. 20 Nov 2026', '+2 kg', 'Kurang 2 kg'),
    _NotaLine('Biji Kopi Arabika', 'Exp. 20 Nov 2026', '+2 kg'),
  ]),
  _Nota('Penerimaan 02', [
    _NotaLine('Biji Kopi Arabika', 'Exp. 20 Nov 2026', '+2 kg'),
  ]),
];

// ============================ PAGE ============================
class DetailNotaPage extends StatelessWidget {
  const DetailNotaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const TerimaTopBar(title: 'Detail Nota'),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(25, 22, 25, 24),
              child: Column(
                children: [
                  for (final n in _dummyNota) ...[
                    _NotaCard(nota: n),
                    const SizedBox(height: 14),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NotaCard extends StatelessWidget {
  final _Nota nota;
  const _NotaCard({required this.nota});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: cardDeco(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(nota.title, style: ts(16, FontWeight.w600, AppColors.brown)),
                  Text('1 item · Rp 90.000', style: ts(12, FontWeight.w400, AppColors.subText)),
                ]),
              ),
              OutlinedButton.icon(
                // TODO FE: ganti placeholder dengan foto nota asli
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => Dialog(
                    backgroundColor: Colors.white,
                    surfaceTintColor: Colors.transparent,
                    child: Container(
                      height: 320,
                      alignment: Alignment.center,
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        const Icon(Icons.receipt_long_outlined,
                            size: 56, color: AppColors.iconBrown),
                        const SizedBox(height: 8),
                        Text('Foto nota belum tersedia',
                            style: ts(12, FontWeight.w500, AppColors.subText)),
                      ]),
                    ),
                  ),
                ),
                icon: const Icon(Icons.photo_camera_outlined, size: 14, color: AppColors.orange),
                label: Text('Lihat Foto Nota', style: ts(12, FontWeight.w500, AppColors.orange)),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 34),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  side: const BorderSide(color: AppColors.orange),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(bottom: 8),
            decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.divider))),
            child: Text('Detail Penerimaan',
                style: ts(16, FontWeight.w600, AppColors.primary)),
          ),
          for (final l in nota.lines)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: AppColors.divider))),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(l.name, style: ts(14, FontWeight.w500, AppColors.brownDark)),
                      Text(l.exp, style: ts(12, FontWeight.w400, AppColors.subText)),
                    ]),
                  ),
                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    Text(l.qty, style: ts(14, FontWeight.w600, AppColors.brownDark)),
                    const SizedBox(height: 2),
                    l.shortage != null
                        ? TBadge(l.shortage!, AppColors.ditolakBg, AppColors.ditolakText)
                        : const TBadge('Sesuai', AppColors.disetujuiBg, AppColors.disetujuiText),
                  ]),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
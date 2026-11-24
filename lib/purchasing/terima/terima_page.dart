import 'package:flutter/material.dart';

import '../partials/colors.dart';
import '../partials/header.dart';
import '../partials/navbar.dart';
import 'detail_nota.dart';
import 'detail_terima.dart';
import 'terima_common.dart';

// ============================ DATA (DUMMY) ============================
List<TerimaItem> _items(int? a, int? b) => [
      TerimaItem('Biji Kopi Arabika', 2, received: a, expiry: a == null ? null : DateTime(2026, 11, 20)),
      TerimaItem('Biji Kopi Arabika', 2, received: b, expiry: b == null ? null : DateTime(2026, 11, 20)),
    ];

final List<TerimaPo> _dummy = [
  TerimaPo('PO-0016', 'PT Abdi Jaya', '1 item · Rp 90.000', TerimaStatus.menunggu, _items(null, null)),
  TerimaPo('PO-0016', 'PT Abdi Jaya', '1 item · Rp 90.000', TerimaStatus.sebagian, _items(null, 2)),
  TerimaPo('PO-0016', 'PT Abdi Jaya', '1 item · Rp 90.000', TerimaStatus.selesai, _items(2, 2),
      receivedDate: '14 November 2026'),
];

const _filters = <MapEntry<String, TerimaStatus?>>[
  MapEntry('Semua', null),
  MapEntry('Menunggu', TerimaStatus.menunggu),
  MapEntry('Sebagian', TerimaStatus.sebagian),
  MapEntry('Selesai', TerimaStatus.selesai),
];

// ============================ PAGE ============================
class TerimaPage extends StatefulWidget {
  const TerimaPage({super.key});

  @override
  State<TerimaPage> createState() => _TerimaPageState();
}

class _TerimaPageState extends State<TerimaPage> {
  int _sel = 0;

  @override
  Widget build(BuildContext context) {
    final f = _filters[_sel].value;
    final list = f == null ? _dummy : _dummy.where((e) => e.status == f).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const AppHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(25, 24, 25, 24),
              child: Column(
                children: [
                  const _Search(),
                  const SizedBox(height: 12),
                  _Chips(selected: _sel, onChanged: (i) => setState(() => _sel = i)),
                  const SizedBox(height: 14),
                  for (final po in list) ...[
                    _PoCard(po: po),
                    const SizedBox(height: 14),
                  ],
                ],
              ),
            ),
          ),
          const AppBottomNav(currentIndex: 3),
        ],
      ),
    );
  }
}

class _Search extends StatelessWidget {
  const _Search();

  @override
  Widget build(BuildContext context) => Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.cardWarnBg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.cardWarnBorder),
        ),
        child: Row(
          children: [
            const Icon(Icons.search, color: AppColors.iconBrown, size: 22),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                style: ts(14, FontWeight.w400, AppColors.brownDark),
                decoration: InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                  hintText: 'Cari nomor PO',
                  hintStyle: ts(14, FontWeight.w400, AppColors.subText.withOpacity(0.7)),
                ),
              ),
            ),
          ],
        ),
      );
}

class _Chips extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onChanged;
  const _Chips({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 34,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: _filters.length,
          separatorBuilder: (_, __) => const SizedBox(width: 6),
          itemBuilder: (_, i) {
            final active = i == selected;
            return GestureDetector(
              onTap: () => onChanged(i),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: active ? AppColors.primary : AppColors.filterItemBg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(_filters[i].key,
                    style: ts(14, FontWeight.w600, active ? Colors.white : AppColors.brown)),
              ),
            );
          },
        ),
      );
}

class _PoCard extends StatelessWidget {
  final TerimaPo po;
  const _PoCard({required this.po});

  void _open(BuildContext c) {
    if (po.status == TerimaStatus.selesai) {
      Navigator.push(c, MaterialPageRoute(builder: (_) => const DetailNotaPage()));
    } else {
      Navigator.push(c, MaterialPageRoute(builder: (_) => DetailTerimaPage(po: po)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final done = po.status == TerimaStatus.selesai;
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: () => _open(context),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 14, 15, 14),
          decoration: cardDeco(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: Text(po.code, style: ts(18, FontWeight.w600, AppColors.brown, h: 1.3))),
                  TBadge.status(po.status),
                ],
              ),
              Text(po.supplier, style: ts(16, FontWeight.w600, AppColors.brownDark, h: 1.3)),
              const SizedBox(height: 2),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(child: Text(po.summary, style: ts(12, FontWeight.w400, AppColors.subText))),
                  if (po.status == TerimaStatus.sebagian)
                    Text('1 dari 2 item\nsudah diterima lengkap',
                        textAlign: TextAlign.right, style: ts(10, FontWeight.w400, AppColors.subText))
                  else if (done)
                    Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                      Text('Diterima', style: ts(10, FontWeight.w400, AppColors.subText)),
                      Text(po.receivedDate ?? '', style: ts(10, FontWeight.w400, AppColors.subText)),
                    ]),
                ],
              ),
              if (!done) ...[
                const SizedBox(height: 12),
                TButton(
                  po.status == TerimaStatus.menunggu ? 'Terima Barang' : 'Lanjut Terima Barang',
                  onTap: () => _open(context),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
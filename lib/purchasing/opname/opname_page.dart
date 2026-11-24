import 'package:flutter/material.dart';

import '../partials/colors.dart';
import '../partials/header.dart';
import '../partials/navbar.dart';
import '../terima/terima_common.dart';
import 'hasil_opname.dart';
import 'input_opname.dart';

// ============================ DATA (DUMMY) ============================
enum OpnameStatus { draft, menunggu, selesai }

class OpnameItem {
  final String name, category;
  final int system;
  int? physical; // null = belum diisi
  OpnameItem(this.name, this.category, this.system, {this.physical});
  int get diff => (physical ?? system) - system;
}

List<OpnameItem> dummyOpnameItems() => [
      OpnameItem('Tepung Terigu', 'Bahan Kering', 16),
      OpnameItem('Gula Pasir', 'Bahan Kering', 10),
      OpnameItem('Susu UHT Full Cream', 'Bahan Cair', 32),
      OpnameItem('Tepung Tapioka', 'Bahan Kering', 8),
      OpnameItem('Biji Kopi Arabika', 'Bahan Kering', 12),
      OpnameItem('Sirup Vanilla', 'Bahan Cair', 6),
    ];

class _Opname {
  final String title, range, time;
  final OpnameStatus status;
  final String? by;
  const _Opname(this.title, this.range, this.time, this.status, [this.by]);
}

const _dummy = [
  _Opname('Opname Mingguan', '9 Nov - 22 Nov', '', OpnameStatus.draft),
  _Opname('Opname Mingguan', '9 Nov - 15 Nov', '15:40 WIB', OpnameStatus.menunggu, 'Menunggu persetujuan Owner'),
  _Opname('Opname Mingguan', '2 Nov - 8 Nov', '15:40 WIB', OpnameStatus.selesai, 'Disetujui Owner'),
];

// ============================ PAGE ============================
class OpnamePage extends StatelessWidget {
  const OpnamePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const AppHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(25, 22, 25, 24),
              child: Column(
                children: [
                  Row(children: const [
                    Expanded(child: _Drop(['2026', '2025'])),
                    SizedBox(width: 10),
                    Expanded(child: _Drop(['November', 'Oktober', 'September'])),
                  ]),
                  const SizedBox(height: 14),
                  for (final o in _dummy) ...[
                    _Card(o: o),
                    const SizedBox(height: 12),
                  ],
                ],
              ),
            ),
          ),
          const AppBottomNav(currentIndex: 4),
        ],
      ),
    );
  }
}

class _Drop extends StatefulWidget {
  final List<String> opts;
  const _Drop(this.opts);

  @override
  State<_Drop> createState() => _DropState();
}

class _DropState extends State<_Drop> {
  late String v = widget.opts.first;

  @override
  Widget build(BuildContext context) => Container(
        height: 42,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: cardDeco(),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: v,
            isExpanded: true,
            icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.brown),
            style: ts(13, FontWeight.w500, AppColors.brownDark),
            items: [for (final o in widget.opts) DropdownMenuItem(value: o, child: Text(o))],
            onChanged: (x) => setState(() => v = x ?? v),
          ),
        ),
      );
}

class _Card extends StatelessWidget {
  final _Opname o;
  const _Card({required this.o});

  @override
  Widget build(BuildContext context) {
    final draft = o.status == OpnameStatus.draft;
    final done = o.status == OpnameStatus.selesai;
    final Color bg = done ? AppColors.disetujuiBg : AppColors.menungguBg;
    final Color fg = done ? AppColors.disetujuiText : AppColors.menungguText;
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => draft
                    ? const InputOpnamePage()
                    : HasilOpnamePage(waiting: o.status == OpnameStatus.menunggu))),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: cardDeco(),
          child: Column(children: [
            Row(children: [
              Container(
                width: 42, height: 42,
                decoration: BoxDecoration(
                    color: draft ? AppColors.iconTile : AppColors.disetujuiBg,
                    borderRadius: BorderRadius.circular(21)),
                child: Icon(draft ? Icons.assignment_outlined : Icons.check,
                    color: draft ? AppColors.iconBrown : AppColors.disetujuiText, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(o.title, style: ts(14, FontWeight.w600, AppColors.brownDark)),
                  Text(o.range, style: ts(11, FontWeight.w400, AppColors.subText)),
                  if (o.time.isNotEmpty) Text(o.time, style: ts(10, FontWeight.w400, AppColors.subText)),
                ]),
              ),
              if (draft) const TBadge('Belum Diisi', AppColors.menungguBg, AppColors.menungguText),
              const Icon(Icons.chevron_right, size: 20, color: AppColors.subText),
            ]),
            if (o.by != null) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(4)),
                child: Text(o.by!, style: ts(10, FontWeight.w500, fg)),
              ),
            ],
          ]),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';

import '../partials/colors.dart';
import '../partials/status_badge.dart';
import 'detail_request.dart';

/// Halaman Riwayat Request Restock - Staff Purchasing
/// Hanya tampilan (UI). Data masih dummy, logic & API dikerjakan FE.
/// Bottom sheet "Filter Riwayat" ada di file yang sama (bagian bawah).

// ============================ MODEL (DUMMY) ============================
class _Riwayat {
  final String code;
  final String date;
  final AppStatus status;
  final int itemCount;
  final String? note;

  const _Riwayat({
    required this.code,
    required this.date,
    required this.status,
    required this.itemCount,
    this.note,
  });
}

const List<_Riwayat> _dummyRiwayat = [
  _Riwayat(
    code: 'RR-241129–002',
    date: '29 Nov 2026, 19:41',
    status: AppStatus.selesai,
    itemCount: 10,
    note: 'PO dibuat pada 31 Nov 2026, 24:00',
  ),
  _Riwayat(
    code: 'RR-241129–002',
    date: '29 Nov 2026, 19:41',
    status: AppStatus.diproses,
    itemCount: 10,
  ),
  _Riwayat(
    code: 'RR-241129–002',
    date: '29 Nov 2026, 19:41',
    status: AppStatus.menunggu,
    itemCount: 10,
  ),
  _Riwayat(
    code: 'RR-241129–002',
    date: '29 Nov 2026, 19:41',
    status: AppStatus.ditolak,
    itemCount: 10,
  ),
];

// ============================ PAGE ============================
class RiwayatRestockPage extends StatelessWidget {
  const RiwayatRestockPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const _TopBar(title: 'Riwayat Request Restock'),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(25, 24, 25, 24),
              child: Column(
                children: [
                  _SearchBar(
                    hint: 'Cari nomor transaksi',
                    onFilterTap: () => showFilterRiwayat(context),
                  ),
                  const SizedBox(height: 12),
                  for (int i = 0; i < _dummyRiwayat.length; i++)
                    _RiwayatRow(
                      item: _dummyRiwayat[i],
                      // warna garis pemisah selang-seling sesuai desain
                      dividerColor: i.isEven
                          ? const Color(0xFFC9C9C9)
                          : AppColors.cardBorder,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================ ITEM RIWAYAT ============================
class _RiwayatRow extends StatelessWidget {
  final _Riwayat item;
  final Color dividerColor;

  const _RiwayatRow({required this.item, required this.dividerColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: dividerColor, width: 1)),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DetailRequestPage(
                code: item.code,
                date: item.date,
                status: item.status,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 6, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
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
                              Text(
                                item.code,
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.brownDark,
                                  height: 1.3,
                                ),
                              ),
                              Text(
                                item.date,
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.brownDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            StatusBadge(status: item.status),
                            const SizedBox(height: 4),
                            Text(
                              '${item.itemCount} Item',
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: AppColors.brownDark,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    if (item.note != null) ...[
                      const SizedBox(height: 6),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 9, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.menungguBg,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          item.note!,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.brown,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 10),
              const Icon(Icons.chevron_right_rounded,
                  color: AppColors.subText, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}

// ======================================================================
//                    FILTER RIWAYAT (BOTTOM SHEET)
// ======================================================================

/// Hasil filter yang dikembalikan saat "Terapkan Filter" ditekan.
class RiwayatFilter {
  final DateTimeRange? range;
  final Set<AppStatus> statuses;

  const RiwayatFilter({this.range, this.statuses = const {}});
}

/// Tampilkan bottom sheet filter riwayat.
Future<RiwayatFilter?> showFilterRiwayat(
  BuildContext context, {
  RiwayatFilter initial = const RiwayatFilter(),
}) {
  return showModalBottomSheet<RiwayatFilter>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => _FilterRiwayatSheet(initial: initial),
  );
}

class _FilterRiwayatSheet extends StatefulWidget {
  final RiwayatFilter initial;

  const _FilterRiwayatSheet({required this.initial});

  @override
  State<_FilterRiwayatSheet> createState() => _FilterRiwayatSheetState();
}

class _FilterRiwayatSheetState extends State<_FilterRiwayatSheet> {
  DateTimeRange? _range;
  late Set<AppStatus> _statuses;

  @override
  void initState() {
    super.initState();
    _range = widget.initial.range;
    _statuses = {...widget.initial.statuses};
  }

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  Future<void> _pickRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDateRange: _range,
    );
    if (picked != null) setState(() => _range = picked);
  }

  void _toggle(AppStatus s) {
    setState(() {
      _statuses.contains(s) ? _statuses.remove(s) : _statuses.add(s);
    });
  }

  void _reset() {
    setState(() {
      _range = null;
      _statuses.clear();
    });
  }

  void _apply() {
    Navigator.pop(context, RiwayatFilter(range: _range, statuses: _statuses));
  }

  @override
  Widget build(BuildContext context) {
    final String dateText = _range == null
        ? 'Pilih Tanggal'
        : '${_fmt(_range!.start)} - ${_fmt(_range!.end)}';

    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SheetHeader(
              title: 'Filter Riwayat',
              subtitle: 'Pilih kategori untuk menyaring riwayat request',
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 23),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 18),
                  // ---------- Waktu ----------
                  const _SectionTitle('Waktu'),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: _pickRange,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      height: 44,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.brown, width: 1),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today_outlined,
                              color: AppColors.brownDark, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              dateText,
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 14,
                                color: _range == null
                                    ? AppColors.subText
                                    : AppColors.brownDark,
                              ),
                            ),
                          ),
                          const Icon(Icons.keyboard_arrow_down_rounded,
                              color: AppColors.brown, size: 24),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  // ---------- Status ----------
                  const _SectionTitle('Status Request'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 3,
                    runSpacing: 6,
                    children: [
                      for (final s in const [
                        AppStatus.selesai,
                        AppStatus.diproses,
                        AppStatus.menunggu,
                        AppStatus.ditolak,
                      ])
                        _StatusFilterChip(
                          status: s,
                          selected: _statuses.contains(s),
                          onTap: () => _toggle(s),
                        ),
                    ],
                  ),
                  const SizedBox(height: 26),
                  // ---------- Tombol ----------
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: _SheetButton(
                          label: 'Reset',
                          icon: Icons.refresh_rounded,
                          background: AppColors.filterItemBg,
                          foreground: AppColors.primary,
                          onTap: _reset,
                        ),
                      ),
                      const SizedBox(width: 13),
                      Expanded(
                        flex: 3,
                        child: _SheetButton(
                          label: 'Terapkan Filter',
                          icon: Icons.check_rounded,
                          background: AppColors.orange,
                          foreground: Colors.white,
                          onTap: _apply,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusFilterChip extends StatelessWidget {
  final AppStatus status;
  final bool selected;
  final VoidCallback onTap;

  const _StatusFilterChip({
    required this.status,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    late final String label;
    late final Color bg;
    late final Color fg;

    switch (status) {
      case AppStatus.selesai:
      case AppStatus.disetujui:
        label = 'Selesai';
        bg = AppColors.disetujuiBg;
        fg = AppColors.disetujuiText;
        break;
      case AppStatus.diproses:
        label = 'Diproses';
        bg = AppColors.diprosesBg;
        fg = AppColors.diprosesText;
        break;
      case AppStatus.menunggu:
        label = 'Menunggu';
        bg = AppColors.menungguBg;
        fg = AppColors.menungguText;
        break;
      case AppStatus.ditolak:
        label = 'Ditolak';
        bg = AppColors.ditolakBg;
        fg = AppColors.ditolakText;
        break;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 28,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(4),
          border: selected ? Border.all(color: fg, width: 1.2) : null,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: fg,
          ),
        ),
      ),
    );
  }
}

// ============================ BAGIAN PENDUKUNG (PRIVATE) ============================

class _TopBar extends StatelessWidget {
  final String title;

  const _TopBar({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 24,
        bottom: 24,
        left: 20,
        right: 20,
      ),
      decoration: BoxDecoration(
        color: AppColors.headerBg,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: InkWell(
              onTap: () => Navigator.maybePop(context),
              customBorder: const CircleBorder(),
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(Icons.arrow_back,
                    color: AppColors.brownDark, size: 24),
              ),
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.brownDark,
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final String hint;
  final VoidCallback onFilterTap;

  const _SearchBar({required this.hint, required this.onFilterTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.cardWarnBg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.cardWarnBorder, width: 1),
            ),
            child: Row(
              children: [
                const Icon(Icons.search, color: AppColors.iconBrown, size: 22),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      color: AppColors.brownDark,
                    ),
                    decoration: InputDecoration(
                      isDense: true,
                      border: InputBorder.none,
                      hintText: hint,
                      hintStyle: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        color: AppColors.subText.withOpacity(0.7),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        InkWell(
          onTap: onFilterTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.cardWarnBg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.cardWarnBorder, width: 1),
            ),
            child: const Icon(Icons.tune_rounded,
                color: AppColors.iconBrown, size: 22),
          ),
        ),
      ],
    );
  }
}

class _SheetHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SheetHeader({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 10),
        Center(
          child: Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.sheetHandle,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(23, 20, 23, 10),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: AppColors.cardWarnBorder, width: 1),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppColors.brownDark,
                        height: 1.2,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: AppColors.subText,
                      ),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: () => Navigator.pop(context),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.filterItemBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.close_rounded,
                      color: AppColors.brownDark, size: 22),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: 'Poppins',
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.sectionTitle,
      ),
    );
  }
}

class _SheetButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color background;
  final Color foreground;
  final VoidCallback onTap;

  const _SheetButton({
    required this.label,
    required this.icon,
    required this.background,
    required this.foreground,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(6),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: foreground, size: 20),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: foreground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
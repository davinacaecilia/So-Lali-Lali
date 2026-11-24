import 'package:flutter/material.dart';

import '../partials/colors.dart';

// ============================ MODEL (DUMMY) ============================
enum TerimaStatus { menunggu, sebagian, selesai }

class TerimaItem {
  final String name;
  final int ordered; // kg
  int? received; // null = belum dicek
  DateTime? expiry;
  String note;

  TerimaItem(this.name, this.ordered, {this.received, this.expiry, this.note = ''});

  bool get checked => received != null;
}

class TerimaPo {
  final String code, supplier, summary;
  final TerimaStatus status;
  final String? receivedDate;
  final List<TerimaItem> items;

  const TerimaPo(this.code, this.supplier, this.summary, this.status,
      this.items, {this.receivedDate});
}

const _bulan = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
String fmtDate(DateTime d) => '${d.day} ${_bulan[d.month - 1]} ${d.year}';

// ============================ STYLE ============================
TextStyle ts(double size, FontWeight w, Color c, {double? h}) =>
    TextStyle(fontFamily: kFont, fontSize: size, fontWeight: w, color: c, height: h);

BoxDecoration cardDeco({Color color = Colors.white}) => BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: AppColors.cardBorder, width: 1),
    );

// ============================ WIDGETS ============================
class TerimaTopBar extends StatelessWidget {
  final String title;
  const TerimaTopBar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 24, bottom: 24, left: 20, right: 20),
      decoration: BoxDecoration(
        color: AppColors.headerBg,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 4, offset: const Offset(0, 2)),
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
                child: Icon(Icons.arrow_back, color: AppColors.brownDark, size: 24),
              ),
            ),
          ),
          Text(title, style: ts(16, FontWeight.w600, AppColors.brownDark)),
        ],
      ),
    );
  }
}

class TBadge extends StatelessWidget {
  final String label;
  final Color bg, fg;
  const TBadge(this.label, this.bg, this.fg, {super.key});

  factory TBadge.status(TerimaStatus s) {
    switch (s) {
      case TerimaStatus.menunggu:
        return const TBadge('Menunggu', AppColors.menungguBg, AppColors.menungguText);
      case TerimaStatus.sebagian:
        return const TBadge('Diterima Sebagian', AppColors.diprosesBg, AppColors.diprosesText);
      case TerimaStatus.selesai:
        return const TBadge('Selesai', AppColors.disetujuiBg, AppColors.disetujuiText);
    }
  }

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
        child: Text(label, style: ts(11, FontWeight.w500, fg)),
      );
}

class TButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool outlined;
  final bool arrow;
  const TButton(this.label, {super.key, this.onTap, this.outlined = false, this.arrow = false});

  @override
  Widget build(BuildContext context) {
    final bool on = onTap != null;
    final Color bg = outlined
        ? Colors.white
        : (on ? AppColors.orange : AppColors.orange.withOpacity(0.35));
    final Color fg = outlined ? AppColors.primary : Colors.white;
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          height: 48,
          width: double.infinity,
          alignment: Alignment.center,
          decoration: outlined
              ? BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.primary))
              : null,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label, style: ts(14, FontWeight.w600, fg)),
              if (arrow) ...[
                const SizedBox(width: 6),
                Icon(Icons.arrow_forward, size: 18, color: fg),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class TWarnBox extends StatelessWidget {
  final String text;
  const TWarnBox(this.text, {super.key});

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.cardWarnBg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.cardWarnBorder),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.info_outline, size: 18, color: AppColors.menungguText),
            const SizedBox(width: 8),
            Expanded(child: Text(text, style: ts(12, FontWeight.w400, AppColors.menungguText, h: 1.4))),
          ],
        ),
      );
}

class TItemTile extends StatelessWidget {
  final String name, sub;
  const TItemTile({super.key, required this.name, required this.sub});

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: AppColors.iconTile, borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.inventory_2, color: AppColors.iconBrown, size: 22),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: ts(14, FontWeight.w600, AppColors.brownDark, h: 1.3)),
              Text(sub, style: ts(11, FontWeight.w400, AppColors.subText)),
            ],
          ),
        ],
      );
}

Widget sectionTitle(String t) => Container(
      width: double.infinity,
      padding: const EdgeInsets.only(bottom: 8),
      decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.divider))),
      child: Text(t, style: ts(15, FontWeight.w600, AppColors.primary)),
    );
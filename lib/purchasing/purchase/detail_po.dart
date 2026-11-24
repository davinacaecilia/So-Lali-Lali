import 'package:flutter/material.dart';

import '../partials/colors.dart';

/// Halaman Detail Purchase Order - Staff Purchasing
/// Hanya tampilan (UI). Data masih dummy, logic & API dikerjakan FE.
///
/// Tampilan mengikuti [PoStatus]:
/// - diterima : strip "PO diterima tanggal ..."
/// - ditolak  : kotak "Alasan Penolakan"
/// - menunggu : info "sedang direview oleh Owner"
/// - diproses : info "sudah dikonfirmasi Owner & dalam proses pengiriman"
/// - draft    : info + qty/harga bisa diedit + tombol "Ajukan Purchase Order"

/// Status PO (dipakai juga oleh purchase_page.dart).
enum PoStatus { draft, menunggu, diproses, ditolak, diterima }

// ============================ MODEL (DUMMY) ============================
class _PoItem {
  final String name;
  final String qty;
  final String price;
  final String subtotal;
  const _PoItem(this.name, this.qty, this.price, this.subtotal);
}

const List<_PoItem> _dummyItems = [
  _PoItem('Biji Kopi Arabika', '2 kg', 'Rp 120.000', 'Rp 240.000'),
  _PoItem('Biji Kopi Arabika', '2 kg', 'Rp 120.000', 'Rp 240.000'),
];

// ============================ PAGE ============================
class DetailPoPage extends StatelessWidget {
  final String code;
  final String date;
  final String requestedBy;
  final String supplier;
  final PoStatus status;
  final String? rejectReason;
  final String receivedAt;

  const DetailPoPage({
    super.key,
    this.code = 'PO-0016',
    this.date = '29 Nov 2026, 19:41',
    this.requestedBy = 'Purchasing 1',
    this.supplier = 'PT Abdi Jaya',
    this.status = PoStatus.diterima,
    this.rejectReason,
    this.receivedAt = '29 Nov 2026, 19:42',
  });

  bool get _isDraft => status == PoStatus.draft;

  String? get _infoText {
    switch (status) {
      case PoStatus.menunggu:
        return 'Permintaan Purchase Order sedang direview oleh Owner';
      case PoStatus.diproses:
        return 'Permintaan Purchase Order sudah dikonfirmasi oleh Owner dan dalam proses pengiriman';
      case PoStatus.draft:
        return 'Pastikan jumlah setiap item sudah sesuai sebelum diajukan kepada Owner.';
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final String? info = _infoText;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const _TopBar(title: 'Detail Purchase Order'),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(25, 22, 25, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _PoHeader(
                    code: code,
                    date: date,
                    requestedBy: requestedBy,
                    status: status,
                  ),
                  if (status == PoStatus.diterima) ...[
                    const SizedBox(height: 8),
                    _ReceivedStrip(text: 'PO diterima tanggal $receivedAt'),
                  ],
                  if (status == PoStatus.ditolak) ...[
                    const SizedBox(height: 12),
                    _RejectBox(reason: rejectReason ?? 'Masih Banyak Stok'),
                  ],
                  if (info != null) ...[
                    const SizedBox(height: 12),
                    _InfoBanner(text: info),
                  ],
                  const SizedBox(height: 14),
                  _SupplierCard(
                    supplier: supplier,
                    editable: _isDraft,
                    showDraftChip: _isDraft,
                  ),
                ],
              ),
            ),
          ),
          if (_isDraft)
            Padding(
              padding: EdgeInsets.fromLTRB(
                25,
                8,
                25,
                MediaQuery.of(context).padding.bottom + 20,
              ),
              child: _PrimaryButton(
                label: 'Ajukan Purchase Order',
                onTap: () async {
                  final messenger = ScaffoldMessenger.of(context);
                  final nav = Navigator.of(context);
                  final ok = await showDialog<bool>(
                    context: context,
                    builder: (c) => AlertDialog(
                      backgroundColor: Colors.white,
                      surfaceTintColor: Colors.transparent,
                      title: const Text('Ajukan Purchase Order?'),
                      content: const Text('PO akan dikirim ke Owner untuk direview.'),
                      actions: [
                        TextButton(
                            onPressed: () => Navigator.pop(c, false),
                            child: const Text('Batal')),
                        TextButton(
                            onPressed: () => Navigator.pop(c, true),
                            child: const Text('Ajukan')),
                      ],
                    ),
                  );
                  // TODO FE: ajukan PO ke API
                  if (ok == true) {
                    messenger.showSnackBar(const SnackBar(
                        content: Text('PO berhasil diajukan ke Owner')));
                    nav.maybePop();
                  }
                },
              ),
            ),
        ],
      ),
    );
  }
}

// ============================ BADGE STATUS PO ============================
/// Badge status PO (dipakai juga oleh purchase_page.dart).
/// [short] = true menampilkan "Menunggu" (bukan "Menunggu Review Owner").
class PoBadge extends StatelessWidget {
  final PoStatus status;
  final bool short;

  const PoBadge({super.key, required this.status, this.short = false});

  @override
  Widget build(BuildContext context) {
    late final String label;
    late final Color bg;
    late final Color fg;

    switch (status) {
      case PoStatus.draft:
        label = 'Draft';
        bg = const Color(0xFFE8D9C0);
        fg = const Color(0xFF6B4A1E);
        break;
      case PoStatus.menunggu:
        label = short ? 'Menunggu' : 'Menunggu Review Owner';
        bg = AppColors.menungguBg;
        fg = AppColors.menungguText;
        break;
      case PoStatus.diproses:
        label = 'Diproses';
        bg = AppColors.diprosesBg;
        fg = AppColors.diprosesText;
        break;
      case PoStatus.ditolak:
        label = short ? 'Ditolak' : 'Ditolak';
        bg = AppColors.ditolakBg;
        fg = AppColors.ditolakText;
        break;
      case PoStatus.diterima:
        label = 'Diterima';
        bg = AppColors.disetujuiBg;
        fg = AppColors.disetujuiText;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: kFont,
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: fg,
        ),
      ),
    );
  }
}

// ============================ TOP BAR ============================
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
              fontFamily: kFont,
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

// ============================ HEADER PO ============================
class _PoHeader extends StatelessWidget {
  final String code;
  final String date;
  final String requestedBy;
  final PoStatus status;

  const _PoHeader({
    required this.code,
    required this.date,
    required this.requestedBy,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.iconTile,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(Icons.monetization_on_outlined,
                  color: AppColors.iconBrown, size: 22),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                code,
                style: const TextStyle(
                  fontFamily: kFont,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.iconBrown,
                ),
              ),
            ),
            PoBadge(status: status, short: true),
          ],
        ),
        const SizedBox(height: 8),
        _InfoLine(label: 'Tanggal & Waktu', value: date),
        const SizedBox(height: 2),
        _InfoLine(label: 'Diajukan Oleh', value: requestedBy),
      ],
    );
  }
}

class _InfoLine extends StatelessWidget {
  final String label;
  final String value;

  const _InfoLine({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: kFont,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.sectionTitle,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontFamily: kFont,
            fontSize: 11,
            fontWeight: FontWeight.w400,
            color: AppColors.brownDark,
          ),
        ),
      ],
    );
  }
}

// ============================ BANNER / NOTIFIKASI ============================
class _ReceivedStrip extends StatelessWidget {
  final String text;

  const _ReceivedStrip({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.filterItemSelectedBg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: kFont,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.brown,
        ),
      ),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  final String text;

  const _InfoBanner({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.filterItemSelectedBg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 1),
            child: Icon(Icons.info_outline_rounded,
                color: AppColors.brown, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontFamily: kFont,
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: AppColors.brown,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RejectBox extends StatelessWidget {
  final String reason;

  const _RejectBox({required this.reason});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.ditolakBg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.error, color: Color(0xFFD32020), size: 18),
              SizedBox(width: 6),
              Text(
                'Alasan Penolakan',
                style: TextStyle(
                  fontFamily: kFont,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFD32020),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              reason,
              style: const TextStyle(
                fontFamily: kFont,
                fontSize: 11,
                fontWeight: FontWeight.w400,
                color: AppColors.brownDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================ KARTU SUPPLIER ============================
class _SupplierCard extends StatelessWidget {
  final String supplier;
  final bool editable;
  final bool showDraftChip;

  const _SupplierCard({
    required this.supplier,
    required this.editable,
    required this.showDraftChip,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.cardBorder, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  supplier,
                  style: const TextStyle(
                    fontFamily: kFont,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.brown,
                  ),
                ),
              ),
              if (showDraftChip) const PoBadge(status: PoStatus.draft),
            ],
          ),
          const SizedBox(height: 10),
          for (final item in _dummyItems) ...[
            _ItemBlock(item: item, editable: editable),
            const SizedBox(height: 10),
          ],
          const _DashedLine(),
          const SizedBox(height: 10),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total PO',
                style: TextStyle(
                  fontFamily: kFont,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: AppColors.brownDark,
                ),
              ),
              Text(
                'Rp 240.000',
                style: TextStyle(
                  fontFamily: kFont,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.brownDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ItemBlock extends StatelessWidget {
  final _PoItem item;
  final bool editable;

  const _ItemBlock({required this.item, required this.editable});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.name,
          style: const TextStyle(
            fontFamily: kFont,
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.brown,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            _AmountField(text: item.qty, editable: editable, width: 62),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                'x',
                style: TextStyle(
                  fontFamily: kFont,
                  fontSize: 11,
                  color: AppColors.subText,
                ),
              ),
            ),
            _AmountField(text: item.price, editable: editable, width: 104),
            const Spacer(),
            Text(
              item.subtotal,
              style: const TextStyle(
                fontFamily: kFont,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.brownDark,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Kotak qty / harga. Read-only (bg krem) atau bisa diedit (bg putih, mode Draft).
class _AmountField extends StatelessWidget {
  final String text;
  final bool editable;
  final double width;

  const _AmountField({
    required this.text,
    required this.editable,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    const TextStyle style = TextStyle(
      fontFamily: kFont,
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: AppColors.brownDark,
    );

    return Container(
      width: width,
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        color: editable ? Colors.white : AppColors.navActiveBg,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: editable ? AppColors.brown : AppColors.cardBorder,
          width: 1,
        ),
      ),
      child: editable
          ? TextFormField(
              initialValue: text,
              style: style,
              decoration: const InputDecoration(
                isDense: true,
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            )
          : Text(text, style: style),
    );
  }
}

class _DashedLine extends StatelessWidget {
  const _DashedLine();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        final int count = (constraints.maxWidth / 6).floor();
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(
            count,
            (_) => Container(width: 3, height: 1, color: AppColors.cardBorder),
          ),
        );
      },
    );
  }
}

// ============================ TOMBOL ============================
class _PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _PrimaryButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: double.infinity,
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.orange,
          borderRadius: BorderRadius.circular(6),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: const TextStyle(
            fontFamily: kFont,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';

import '../partials/colors.dart';
import '../partials/status_badge.dart';

enum RequestStage {
  menungguOwner,
  diprosesPurchasing,
  poMenungguVerifikasi,
  poSelesai,
  requestDitolak,
  poDitolak,
}

// ============================ MODEL (DUMMY) ============================
enum _PoTag { belumPo, sudahPo }

class _Product {
  final String name;
  final String qty;
  final _PoTag? tag;
  const _Product(this.name, this.qty, {this.tag});
}

const List<_Product> _dummyProducts = [
  _Product('Biji Kopi Arabika', '18 g'),
  _Product('Biji Kopi Arabika', '18 g'),
  _Product('Biji Kopi Arabika', '18 g'),
];

// Dipakai saat stage diprosesPurchasing (ada label Belum PO / Sudah PO)
const List<_Product> _dummyProductsBuatPo = [
  _Product('Biji Kopi Arabika', '18 g', tag: _PoTag.belumPo),
  _Product('Biji Kopi Arabika', '18 g', tag: _PoTag.sudahPo),
];

class _Step {
  final String title;
  final String date;
  final Color color;
  const _Step(this.title, this.date, this.color);
}

// ============================ PAGE ============================
class DetailRequestPage extends StatelessWidget {
  final String code;
  final String date;
  final String requestedBy;

  /// Dipakai untuk menurunkan [stage] jika [stage] tidak diisi.
  final AppStatus status;

  /// Isi untuk memilih tampilan secara spesifik (mis. poMenungguVerifikasi).
  final RequestStage? stage;

  final String? rejectReason;

  const DetailRequestPage({
    super.key,
    this.code = 'RR-241129–002',
    this.date = '29 Nov 2026, 19:41',
    this.requestedBy = 'Kitchen Staff 1',
    this.status = AppStatus.selesai,
    this.stage,
    this.rejectReason,
  });

  // ---------- turunan dari stage ----------
  RequestStage get _stage {
    if (stage != null) return stage!;
    switch (status) {
      case AppStatus.menunggu:
        return RequestStage.menungguOwner;
      case AppStatus.diproses:
        return RequestStage.diprosesPurchasing;
      case AppStatus.selesai:
      case AppStatus.disetujui:
        return RequestStage.poSelesai;
      case AppStatus.ditolak:
        return RequestStage.requestDitolak;
    }
  }

  AppStatus get _badge {
    switch (_stage) {
      case RequestStage.menungguOwner:
        return AppStatus.menunggu;
      case RequestStage.diprosesPurchasing:
      case RequestStage.poMenungguVerifikasi:
        return AppStatus.diproses;
      case RequestStage.poSelesai:
        return AppStatus.selesai;
      case RequestStage.requestDitolak:
      case RequestStage.poDitolak:
        return AppStatus.ditolak;
    }
  }

  bool get _isRejected =>
      _stage == RequestStage.requestDitolak || _stage == RequestStage.poDitolak;

  List<_Step> get _steps {
    const String d = '24 November 2026, 20:00';
    const Color orange = AppColors.orange;
    const Color pale = Color(0xFFFDE5B0);
    const Color blue = AppColors.primary;
    const Color grey = Color(0xFFE3E3E8);
    const Color green = Color(0xFF2E7D32);
    const Color red = Color(0xFFD32020);

    switch (_stage) {
      case RequestStage.menungguOwner:
        return const [
          _Step('Request Restock Diajukan', d, orange),
          _Step('Menunggu Verifikasi Owner', d, grey),
        ];
      case RequestStage.diprosesPurchasing:
        return const [
          _Step('Request Restock Diajukan', d, orange),
          _Step('Request Disetujui Owner', d, pale),
          _Step('Request Sedang Diproses Purchasing', d, grey),
        ];
      case RequestStage.poMenungguVerifikasi:
        return const [
          _Step('Request Restock Diajukan', d, orange),
          _Step('Request Disetujui Owner', d, pale),
          _Step('PO Dibuat Purchasing', d, blue),
          _Step('Menunggu Verifikasi Owner', d, grey),
        ];
      case RequestStage.poSelesai:
        return const [
          _Step('Request Restock Diajukan', d, orange),
          _Step('Request Disetujui Owner', d, pale),
          _Step('PO Dibuat Purchasing', d, blue),
          _Step('PO Disetujui Owner', d, green),
        ];
      case RequestStage.requestDitolak:
        return const [
          _Step('Request Restock Diajukan', d, orange),
          _Step('Request Ditolak Owner', d, red),
        ];
      case RequestStage.poDitolak:
        return const [
          _Step('Request Restock Diajukan', d, orange),
          _Step('Request Disetujui Owner', d, pale),
          _Step('PO Dibuat Purchasing', d, blue),
          _Step('PO Ditolak Owner', d, red),
        ];
    }
  }

  List<_Product> get _products => _stage == RequestStage.diprosesPurchasing
      ? _dummyProductsBuatPo
      : _dummyProducts;

  String? get _buttonLabel {
    switch (_stage) {
      case RequestStage.poSelesai:
        return 'Lihat Detail Purchase Order';
      case RequestStage.diprosesPurchasing:
        return 'Buat Purchase Order';
      default:
        return null;
    }
  }

  void _onButtonTap(BuildContext context) {
    // TODO FE:
    // - poSelesai          -> buka halaman Detail Purchase Order
    // - diprosesPurchasing -> buka halaman Buat PO
  }

  @override
  Widget build(BuildContext context) {
    final String? buttonLabel = _buttonLabel;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const _TopBar(title: 'Detail Request'),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(25, 22, 25, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _RequestHeader(
                    code: code,
                    date: date,
                    requestedBy: requestedBy,
                    status: _badge,
                  ),
                  const SizedBox(height: 22),
                  const _SectionTitle('Progress Request'),
                  const SizedBox(height: 18),
                  _Timeline(steps: _steps),
                  if (_isRejected) ...[
                    const SizedBox(height: 14),
                    _RejectBox(reason: rejectReason ?? 'Masih Banyak Stok'),
                  ],
                  const SizedBox(height: 22),
                  const _SectionTitle('Daftar Produk'),
                  const SizedBox(height: 12),
                  const _NeededBefore(date: '27 November 2026'),
                  const SizedBox(height: 10),
                  for (final p in _products) ...[
                    _ProductRow(product: p),
                    const SizedBox(height: 10),
                  ],
                  if (buttonLabel != null) ...[
                    const SizedBox(height: 24),
                    _PrimaryButton(
                      label: buttonLabel,
                      onTap: () => _onButtonTap(context),
                    ),
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

// ============================ HEADER REQUEST ============================
class _RequestHeader extends StatelessWidget {
  final String code;
  final String date;
  final String requestedBy;
  final AppStatus status;

  const _RequestHeader({
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
              child: const Icon(Icons.assignment_outlined,
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
            StatusBadge(status: status),
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

// ============================ SECTION TITLE ============================
class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          text,
          style: const TextStyle(
            fontFamily: kFont,
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 4),
        const Divider(height: 1, thickness: 1, color: AppColors.cardBorder),
      ],
    );
  }
}

// ============================ TIMELINE ============================
class _Timeline extends StatelessWidget {
  final List<_Step> steps;

  const _Timeline({required this.steps});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < steps.length; i++)
          _TimelineItem(
            step: steps[i],
            nextColor: i < steps.length - 1 ? steps[i + 1].color : null,
          ),
      ],
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final _Step step;
  final Color? nextColor; // null = langkah terakhir (tanpa garis)

  const _TimelineItem({required this.step, required this.nextColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 14,
          child: Column(
            children: [
              Container(
                width: 14,
                height: 14,
                decoration:
                    BoxDecoration(color: step.color, shape: BoxShape.circle),
              ),
              if (nextColor != null)
                Container(
                  width: 2,
                  height: 28,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [step.color, nextColor!],
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                step.title,
                style: const TextStyle(
                  fontFamily: kFont,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.brownDark,
                  height: 1.3,
                ),
              ),
              Text(
                step.date,
                style: const TextStyle(
                  fontFamily: kFont,
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  color: AppColors.menungguText,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ============================ ALASAN PENOLAKAN ============================
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

// ============================ DAFTAR PRODUK ============================
class _NeededBefore extends StatelessWidget {
  final String date;

  const _NeededBefore({required this.date});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.cardWarnBg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Dibutuhkan Sebelum',
            style: TextStyle(
              fontFamily: kFont,
              fontSize: 10,
              fontWeight: FontWeight.w400,
              color: AppColors.sectionTitle,
            ),
          ),
          Text(
            date,
            style: const TextStyle(
              fontFamily: kFont,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.brownDark,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductRow extends StatelessWidget {
  final _Product product;

  const _ProductRow({required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.brown, width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        product.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: kFont,
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: AppColors.brownDark,
                        ),
                      ),
                    ),
                    if (product.tag != null) ...[
                      const SizedBox(width: 8),
                      _PoTagChip(tag: product.tag!),
                    ],
                  ],
                ),
              ),
            ),
            Container(
              width: 90,
              height: double.infinity,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: AppColors.navActiveBg,
                border: Border(
                  left: BorderSide(color: AppColors.brown, width: 1),
                ),
              ),
              child: Text(
                product.qty,
                style: const TextStyle(
                  fontFamily: kFont,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.brownDark,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PoTagChip extends StatelessWidget {
  final _PoTag tag;

  const _PoTagChip({required this.tag});

  @override
  Widget build(BuildContext context) {
    final bool belum = tag == _PoTag.belumPo;
    final Color bg = belum ? AppColors.ditolakBg : AppColors.disetujuiBg;
    final Color fg = belum ? AppColors.ditolakText : AppColors.disetujuiText;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: fg.withOpacity(0.35), width: 0.8),
      ),
      child: Text(
        belum ? 'Belum PO' : 'Sudah PO',
        style: TextStyle(
          fontFamily: kFont,
          fontSize: 9,
          fontWeight: FontWeight.w500,
          color: fg,
        ),
      ),
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
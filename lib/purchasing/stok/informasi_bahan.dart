import 'package:flutter/material.dart';

import '../partials/colors.dart';
import 'filter_bahan.dart' show StokStatus;

/// Halaman Informasi Bahan - Staff Purchasing
/// Hanya tampilan (UI). Data batch masih dummy, logic & API dikerjakan FE.

// ============================ MODEL (DUMMY) ============================
class _Alert {
  final String title;
  final String message;
  const _Alert(this.title, this.message);
}

class _Batch {
  final String name;
  final String stok;
  final String baikSebelum;
  final List<String> tags;
  final List<_Alert> alerts;

  const _Batch({
    required this.name,
    required this.stok,
    required this.baikSebelum,
    this.tags = const [],
    this.alerts = const [],
  });
}

const List<_Batch> _dummyBatches = [
  _Batch(
    name: 'Batch 02',
    stok: '4 kg',
    baikSebelum: '28 November 2026',
    tags: ['Stok Menipis', 'Akan Kadaluwarsa'],
    alerts: [
      _Alert('Stok Mencapai Batas Minimal', 'Segera ajukan restock bahan.'),
      _Alert('Kadaluwarsa dalam 24 hari',
          'Gunakan batch ini lebih dulu.'),
    ],
  ),
  _Batch(
    name: 'Batch 03',
    stok: '12 kg',
    baikSebelum: '12 Januari 2027',
  ),
];

// ============================ PAGE ============================
class InformasiBahanPage extends StatelessWidget {
  final String name;
  final String category;
  final StokStatus status;
  final String? imageAsset;

  const InformasiBahanPage({
    super.key,
    this.name = 'Tepung Terigu Protein Tinggi',
    this.category = 'Bahan Kering',
    this.status = StokStatus.aman,
    this.imageAsset = 'assets/images/tepung.png',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const _TopBar(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(top: 19, bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _ImageHeader(imageAsset: imageAsset, status: status),
                        const SizedBox(height: 14),
                        Text(
                          name,
                          style: const TextStyle(
                            fontFamily: kFont,
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: AppColors.brownDark,
                            height: 1.25,
                          ),
                        ),
                        Text(
                          category,
                          style: const TextStyle(
                            fontFamily: kFont,
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: AppColors.brownDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  const _InfoCard(),
                  const SizedBox(height: 28),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Expanded(
                              child: Text(
                                'Persediaan',
                                style: TextStyle(
                                  fontFamily: kFont,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                // TODO FE: buka form tambah batch
                              },
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: AppColors.orange,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.add,
                                    color: Colors.white, size: 22),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        const Divider(
                          height: 1,
                          thickness: 1,
                          color: AppColors.cardBorder,
                        ),
                        const SizedBox(height: 16),
                        const _TotalCard(),
                        const SizedBox(height: 16),
                        for (final batch in _dummyBatches) ...[
                          _BatchCard(batch: batch),
                          const SizedBox(height: 16),
                        ],
                      ],
                    ),
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

// ============================ TOP BAR ============================
class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.headerBg,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 52,
        bottom: 16,
        left: 20,
        right: 20,
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
          const Text(
            'Informasi Bahan',
            style: TextStyle(
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

// ============================ GAMBAR + BADGE ============================
class _ImageHeader extends StatelessWidget {
  final String? imageAsset;
  final StokStatus status;

  const _ImageHeader({required this.imageAsset, required this.status});

  @override
  Widget build(BuildContext context) {
    late final String label;
    late final IconData icon;
    late final Color bg;
    late final Color fg;

    switch (status) {
      case StokStatus.menipis:
        label = 'Stok Menipis';
        icon = Icons.warning_rounded;
        bg = AppColors.menipisChipBg;
        fg = AppColors.menipisChipText;
        break;
      case StokStatus.habis:
        label = 'Stok Habis';
        icon = Icons.cancel;
        bg = AppColors.habisChipBg;
        fg = AppColors.habisChipText;
        break;
      case StokStatus.aman:
      case StokStatus.semua:
        label = 'Stok Aman';
        icon = Icons.check_circle;
        bg = AppColors.amanChipBg;
        fg = AppColors.amanChipText;
        break;
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: SizedBox(
        width: double.infinity,
        height: 168,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (imageAsset != null)
              Image.asset(
                imageAsset!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const _ImagePlaceholder(),
              )
            else
              const _ImagePlaceholder(),
            Positioned(
              top: 10,
              right: 6,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, color: fg, size: 14),
                    const SizedBox(width: 5),
                    Text(
                      label,
                      style: TextStyle(
                        fontFamily: kFont,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: fg,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.tilePeach,
      alignment: Alignment.center,
      child: const Icon(Icons.inventory_2_outlined,
          color: AppColors.iconBrown, size: 48),
    );
  }
}

// ============================ INFO CARD ============================
class _InfoCard extends StatelessWidget {
  const _InfoCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Column(
        children: [
          _InfoRow(label: 'Stok Minimal', value: '10 kg'),
          Divider(height: 1, thickness: 1, color: AppColors.divider),
          _InfoRow(label: 'Batas Kadaluwarsa', value: '180 hari'),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: kFont,
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppColors.sectionTitle,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontFamily: kFont,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.brownDark,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================ TOTAL ============================
class _TotalCard extends StatelessWidget {
  const _TotalCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      decoration: BoxDecoration(
        color: AppColors.filterItemBg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total 16 kg dalam 2 batch',
            style: TextStyle(
              fontFamily: kFont,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.brownDark,
              height: 1.3,
            ),
          ),
          Text(
            'Diurutkan dari tanggal kadaluwarsa terdekat',
            style: TextStyle(
              fontFamily: kFont,
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: AppColors.sectionTitle,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================ BATCH CARD ============================
class _BatchCard extends StatelessWidget {
  final _Batch batch;

  const _BatchCard({required this.batch});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.orange, width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(7),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 14, 15, 14),
              child: Column(
                children: [
                  // Nama batch + tag
                  Row(
                    children: [
                      Text(
                        batch.name,
                        style: const TextStyle(
                          fontFamily: kFont,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.brownDark,
                        ),
                      ),
                      const SizedBox(width: 10),
                      for (int i = 0; i < batch.tags.length; i++) ...[
                        if (i > 0) const SizedBox(width: 6),
                        _TagChip(label: batch.tags[i]),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  _DetailRow(label: 'Stok', value: batch.stok),
                  const SizedBox(height: 2),
                  _DetailRow(label: 'Baik Sebelum', value: batch.baikSebelum),
                ],
              ),
            ),
            if (batch.alerts.isNotEmpty)
              Container(
                width: double.infinity,
                color: AppColors.filterItemSelectedBg,
                padding: const EdgeInsets.fromLTRB(15, 12, 15, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (int i = 0; i < batch.alerts.length; i++) ...[
                      if (i > 0) const SizedBox(height: 10),
                      _AlertRow(alert: batch.alerts[i]),
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  final String label;

  const _TagChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.pillBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.warning_rounded,
              color: AppColors.sectionTitle, size: 13),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontFamily: kFont,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.sectionTitle,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: kFont,
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: AppColors.subText,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontFamily: kFont,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.brownDark,
          ),
        ),
      ],
    );
  }
}

class _AlertRow extends StatelessWidget {
  final _Alert alert;

  const _AlertRow({required this.alert});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 2),
          child: Icon(Icons.error, color: AppColors.sectionTitle, size: 18),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                alert.title,
                style: const TextStyle(
                  fontFamily: kFont,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.sectionTitle,
                  height: 1.3,
                ),
              ),
              Text(
                alert.message,
                style: const TextStyle(
                  fontFamily: kFont,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: AppColors.brownDark,
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
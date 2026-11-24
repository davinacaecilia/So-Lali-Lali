import 'package:flutter/material.dart';

import '../partials/colors.dart';
import 'filter_bahan.dart';
import 'edit_bahan.dart';
import 'tambah_bahan.dart';

// =====================================================
// MODEL BATCH
// =====================================================
class BatchItem {
  final String name; // mis. "Batch 02"
  final double stock;
  final DateTime expiry;

  const BatchItem({
    required this.name,
    required this.stock,
    required this.expiry,
  });
}

/// Data contoh (sama seperti desain). Nanti ganti dengan data dari API.
final List<BatchItem> kSampleBatches = [
  BatchItem(name: 'Batch 02', stock: 4, expiry: DateTime(2026, 11, 28)),
  BatchItem(name: 'Batch 03', stock: 12, expiry: DateTime(2027, 1, 12)),
];

/// Warna tambahan khusus halaman ini
class _C {
  static const label = AppColors.warmLabel;
  static const divider = AppColors.cardBorder;
  static const rowDivider = AppColors.rowDivider;
  static const chipBg = AppColors.chipBg;
  static const warnBg = AppColors.warningBg;
  static const warnIcon = AppColors.warningIcon;
  static const subtitle = AppColors.warmSubtitle;
  static const grey = AppColors.neutralText;
  static const summarySub = AppColors.summarySubtitle;

  // status: aman
  static const amanBg = AppColors.safeBg;
  static const amanFg = AppColors.safeText;
  // status: menipis
  static const menipisBg = AppColors.warningStatusBg;
  static const menipisFg = AppColors.warningStatusText;
  // status: habis
  static const habisBg = AppColors.exhaustedStatusBg;
  static const habisFg = AppColors.red;
}

// =====================================================
// HALAMAN
// =====================================================
class InformasiBahanPage extends StatelessWidget {
  final String name;
  final String category;
  final String? id;
  final String unit; // satuan, mis. "kg"
  final double minStock;
  final int expiryLimitDays; // batas kadaluwarsa (hari)
  final StockStatus status;
  final IconData icon; // dipakai kalau gambar tidak ada
  final String? imageAsset;
  final List<BatchItem>? batches;

  /// Batch dianggap "akan kadaluwarsa" jika sisa harinya <= nilai ini.
  final int warningDays;

  const InformasiBahanPage({
    super.key,
    required this.name,
    required this.category,
    this.id = 'BBO-WHT-004',
    this.unit = 'kg',
    this.minStock = 10,
    this.expiryLimitDays = 180,
    this.status = StockStatus.aman,
    this.icon = Icons.inventory_2_outlined,
    this.imageAsset,
    this.batches,
    this.warningDays = 30,
  });

  // ---------- helper ----------
  static const _bulan = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  static String _fmtDate(DateTime d) =>
      '${d.day} ${_bulan[d.month - 1]} ${d.year}';

  static String _fmtNum(double v) {
    final s = v == v.roundToDouble() ? v.toInt().toString() : v.toString();
    return s.replaceAll('.', ',');
  }

  static int _daysLeft(DateTime expiry) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(expiry.year, expiry.month, expiry.day);
    return target.difference(today).inDays;
  }

  List<BatchItem> get _batches {
    final list = List<BatchItem>.from(batches ?? kSampleBatches);
    list.sort((a, b) => a.expiry.compareTo(b.expiry)); // terdekat dulu
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final list = _batches;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(25, 20, 25, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildImage(),
                  const SizedBox(height: 14),
                  Text(
                    name,
                    style: const TextStyle(
                      fontFamily: kFont,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                      height: 1.2,
                    ),
                  ),
                  if (id != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      'ID: $id',
                      style: const TextStyle(
                        fontFamily: kFont,
                        fontSize: 11,
                        color: _C.grey,
                      ),
                    ),
                  ],
                  const SizedBox(height: 28),
                  _buildDetailHeader(context),
                  const SizedBox(height: 12),
                  _buildDetailCard(),
                  const SizedBox(height: 24),
                  _buildPersediaanHeader(context),
                  const SizedBox(height: 12),
                  if (list.isEmpty)
                    _buildEmptyBatch()
                  else ...[
                    _buildSummary(list),
                    const SizedBox(height: 16),
                    for (final b in list) ...[
                      _buildBatchCard(b),
                      const SizedBox(height: 12),
                    ],
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= HEADER =================
  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.headerBg,
        boxShadow: [
          BoxShadow(
            color: AppColors.overlayShadow,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 64,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  padding: const EdgeInsets.only(left: 25),
                  onPressed: () => Navigator.maybePop(context),
                  icon: const Icon(
                    Icons.arrow_back,
                    color: AppColors.textDark,
                    size: 22,
                  ),
                ),
              ),
              const Text(
                'Informasi Bahan',
                style: TextStyle(
                  fontFamily: kFont,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= GAMBAR + BADGE STATUS =================
  Widget _buildImage() {
    late final String label;
    late final IconData badgeIcon;
    late final Color bg;
    late final Color fg;

    switch (status) {
      case StockStatus.aman:
        label = 'Stok Aman';
        badgeIcon = Icons.check_circle;
        bg = _C.amanBg;
        fg = _C.amanFg;
        break;
      case StockStatus.menipis:
        label = 'Stok Menipis';
        badgeIcon = Icons.warning_rounded;
        bg = _C.menipisBg;
        fg = _C.menipisFg;
        break;
      case StockStatus.habis:
        label = 'Stok Habis';
        badgeIcon = Icons.cancel;
        bg = _C.habisBg;
        fg = _C.habisFg;
        break;
    }

    final fallback = Container(
      color: AppColors.iconBox,
      child: Icon(icon, size: 56, color: AppColors.brown),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: SizedBox(
        height: 168,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (imageAsset != null)
              Image.asset(
                imageAsset!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => fallback,
              )
            else
              fallback,
            Positioned(
              top: 8,
              right: 6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(badgeIcon, size: 13, color: fg),
                    const SizedBox(width: 4),
                    Text(
                      label,
                      style: TextStyle(
                        fontFamily: kFont,
                        fontSize: 11,
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

  // ================= DETAIL BAHAN =================
  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: kFont,
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColors.barDark,
      ),
    );
  }

  Widget _buildDetailHeader(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _sectionTitle('Detail Bahan'),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditInformasiBahanPage(
                      name: name,
                      category: category,
                      unit: unit,
                      minStock: minStock,
                      expiryLimitDays: expiryLimitDays,
                      imageAsset: imageAsset,
                    ),
                  ),
                );
              },
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(
                  Icons.edit_outlined,
                  size: 20,
                  color: AppColors.barDark,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(height: 1, color: _C.divider),
      ],
    );
  }

  Widget _buildDetailCard() {
    final rows = <List<String>>[
      ['Nama Bahan', name],
      ['Kategori Bahan', category],
      ['Satuan', unit],
      ['Stok Minimal', '${_fmtNum(minStock)} $unit'],
      ['Batas Kadaluwarsa', '$expiryLimitDays hari'],
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: AppColors.subtleShadow,
            blurRadius: 6,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          for (int i = 0; i < rows.length; i++) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    rows[i][0],
                    style: const TextStyle(
                      fontFamily: kFont,
                      fontSize: 13,
                      color: _C.label,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Text(
                      rows[i][1],
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontFamily: kFont,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (i != rows.length - 1)
              Container(height: 1, color: _C.rowDivider),
          ],
        ],
      ),
    );
  }

  // ================= PERSEDIAAN =================
  Widget _buildPersediaanHeader(BuildContext context) {
  return Column(
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _sectionTitle('Persediaan'),
          Material(
            color: AppColors.orange,
            borderRadius: BorderRadius.circular(8),
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const TambahBahanBaruPage(),
                  ),
                );
              },
              child: const SizedBox(
                width: 42,
                height: 42,
                child: Icon(Icons.add, color: Colors.white, size: 22),
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 6),
      Container(height: 1, color: _C.divider),
    ],
  );
}

  Widget _buildSummary(List<BatchItem> list) {
    final total = list.fold<double>(0, (sum, b) => sum + b.stock);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total ${_fmtNum(total)} $unit dalam ${list.length} batch',
            style: const TextStyle(
              fontFamily: kFont,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'Diurutkan dari tanggal kadaluwarsa terdekat',
            style: TextStyle(
              fontFamily: kFont,
              fontSize: 11,
              color: _C.summarySub,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyBatch() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Column(
        children: [
          Icon(Icons.inventory_2_outlined, size: 30, color: AppColors.brown),
          SizedBox(height: 10),
          Text(
            'Belum ada batch persediaan',
            style: TextStyle(
              fontFamily: kFont,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
          SizedBox(height: 2),
          Text(
            'Tekan tombol + untuk menambah batch.',
            style: TextStyle(
              fontFamily: kFont,
              fontSize: 12,
              color: _C.subtitle,
            ),
          ),
        ],
      ),
    );
  }

  // ================= KARTU BATCH =================
  Widget _batchRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: kFont,
            fontSize: 14,
            color: AppColors.neutralSubtitle,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontFamily: kFont,
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
      ],
    );
  }

  Widget _buildBatchCard(BatchItem b) {
    final days = _daysLeft(b.expiry);
    final expired = days < 0;
    final warning = days <= warningDays; // termasuk yang sudah lewat

    final body = Padding(
      padding: const EdgeInsets.fromLTRB(15, 14, 15, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                b.name,
                style: const TextStyle(
                  fontFamily: kFont,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              if (warning)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: _C.chipBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.warning_rounded,
                        size: 13,
                        color: AppColors.brownDark,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        expired ? 'Kadaluwarsa' : 'Akan Kadaluwarsa',
                        style: const TextStyle(
                          fontFamily: kFont,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.brownDark,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          _batchRow('Stok', '${_fmtNum(b.stock)} $unit'),
          const SizedBox(height: 4),
          _batchRow('Baik Sebelum', _fmtDate(b.expiry)),
        ],
      ),
    );

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.orange, width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          body,
          if (warning)
            Container(
              width: double.infinity,
              color: _C.warnBg,
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: Row(
                children: [
                  const Icon(Icons.error, size: 18, color: _C.warnIcon),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          expired
                              ? 'Sudah kadaluwarsa ${-days} hari lalu'
                              : days == 0
                              ? 'Kadaluwarsa hari ini'
                              : 'Kadaluwarsa dalam $days hari',
                          style: const TextStyle(
                            fontFamily: kFont,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.brownDark,
                          ),
                        ),
                        Text(
                          expired
                              ? 'Jangan digunakan, segera buang batch ini.'
                              : 'Gunakan batch ini lebih dulu.',
                          style: const TextStyle(
                            fontFamily: kFont,
                            fontSize: 12,
                            color: _C.subtitle,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

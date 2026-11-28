import 'package:flutter/material.dart';

import '../../constants/ingredient_options.dart';
import '../../models/ingredient.dart';
import '../../services/ingredient_service.dart';
import '../partials/colors.dart';
import 'edit_bahan.dart';
import 'filter_bahan.dart' show StockStatus;

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

StockStatus _statusOf(Ingredient i) {
  if (i.totalStock <= 0) return StockStatus.habis;
  if (i.totalStock < i.minStock) return StockStatus.menipis;
  return StockStatus.aman;
}

IconData _iconFor(String categoryKey) {
  switch (categoryKey) {
    case 'bahan_kering':
      return Icons.grain;
    case 'susu_olahan':
      return Icons.local_drink_outlined;
    case 'daging_unggas':
      return Icons.kebab_dining;
    case 'seafood':
      return Icons.set_meal_outlined;
    case 'telur':
      return Icons.egg_outlined;
    case 'sayur_buah':
      return Icons.eco_outlined;
    case 'bumbu_rempah':
      return Icons.spa_outlined;
    case 'minyak_lemak':
      return Icons.water_drop_outlined;
    case 'minuman_sirup':
      return Icons.coffee_outlined;
    case 'bahan_beku':
      return Icons.ac_unit;
    default:
      return Icons.category_outlined;
  }
}

// =====================================================
// HALAMAN
// =====================================================
class InformasiBahanPage extends StatefulWidget {
  final String ingredientId;

  const InformasiBahanPage({super.key, required this.ingredientId});

  @override
  State<InformasiBahanPage> createState() => _InformasiBahanPageState();
}

class _InformasiBahanPageState extends State<InformasiBahanPage> {
  late final Stream<Ingredient?> _ingredientStream =
  IngredientService.instance.watchOne(widget.ingredientId);
  late final Stream<List<Batch>> _batchStream =
  IngredientService.instance.watchBatches(widget.ingredientId);

  // ---------- aksi ----------
  Future<void> _edit(Ingredient ing) async {
    final result = await Navigator.push<EditBahanResult>(
      context,
      MaterialPageRoute(
        builder: (_) => EditInformasiBahanPage(ingredient: ing),
      ),
    );
    // Bahan dihapus -> tutup halaman detail, kembali ke daftar.
    if (result?.deleted == true && mounted) Navigator.pop(context);
  }

  void _tambahPersediaan() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text(
            'Penambahan persediaan menyusul (menunggu alur PO / request restock)',
          ),
        ),
      );
  }

  // ------------------------------------------------------------
  // BUILD
  // ------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: StreamBuilder<Ingredient?>(
              stream: _ingredientStream,
              builder: (context, snap) {
                if (snap.hasError) {
                  return _centerMessage('Gagal memuat data bahan.');
                }
                if (snap.connectionState == ConnectionState.waiting &&
                    !snap.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.orange),
                  );
                }
                final ing = snap.data;
                if (ing == null || !ing.isActive) {
                  return _centerMessage('Bahan tidak ditemukan.');
                }
                return _buildContent(ing);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _centerMessage(String text) {
    return Center(
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: kFont,
          fontSize: 14,
          color: AppColors.neutralText,
        ),
      ),
    );
  }

  Widget _buildContent(Ingredient ing) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(25, 20, 25, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildImage(ing),
          const SizedBox(height: 14),
          Text(
            ing.name,
            style: const TextStyle(
              fontFamily: kFont,
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'ID: ${ing.code}',
            style: const TextStyle(
              fontFamily: kFont,
              fontSize: 11,
              color: _C.grey,
            ),
          ),
          const SizedBox(height: 28),
          _buildDetailHeader(ing),
          const SizedBox(height: 12),
          _buildDetailCard(ing),
          const SizedBox(height: 24),
          _buildPersediaanHeader(),
          const SizedBox(height: 12),
          StreamBuilder<List<Batch>>(
            stream: _batchStream,
            builder: (context, snap) {
              if (snap.hasError) {
                return _centerMessage('Gagal memuat persediaan.');
              }
              if (!snap.hasData) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.orange),
                  ),
                );
              }
              final list = snap.data!;
              if (list.isEmpty) return _buildEmptyBatch();

              return Column(
                children: [
                  _buildSummary(ing, list),
                  const SizedBox(height: 16),
                  for (final b in list) ...[
                    _buildBatchCard(b, ing),
                    const SizedBox(height: 12),
                  ],
                ],
              );
            },
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
  Widget _buildImage(Ingredient ing) {
    late final String label;
    late final IconData badgeIcon;
    late final Color bg;
    late final Color fg;

    switch (_statusOf(ing)) {
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

    // Placeholder (dipakai kalau foto tidak ada / gagal dimuat)
    final fallback = Container(
      color: AppColors.iconBox,
      child: Icon(_iconFor(ing.categoryKey), size: 56, color: AppColors.brown),
    );

    Widget photo = fallback;
    final url = ing.photoUrl;
    if (url != null && url.isNotEmpty) {
      photo = Image.network(
        cloudinaryResize(url, width: 900),
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) =>
        progress == null ? child : fallback,
        errorBuilder: (_, __, ___) => fallback,
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: SizedBox(
        height: 168,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            photo,
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

  Widget _buildDetailHeader(Ingredient ing) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _sectionTitle('Detail Bahan'),
            InkWell(
              onTap: () => _edit(ing),
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

  Widget _buildDetailCard(Ingredient ing) {
    final rows = <List<String>>[
      ['Nama Bahan', ing.name],
      ['Kategori Bahan', ing.category.label],
      ['Satuan', ing.unit.label],
      ['Stok Minimal', formatQty(ing.minStock, ing.unit)],
      ['Batas Kadaluwarsa', '${ing.shelfLifeValue} ${ing.shelfLifeUnit}'],
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
  Widget _buildPersediaanHeader() {
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
                onTap: _tambahPersediaan,
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

  Widget _buildSummary(Ingredient ing, List<Batch> list) {
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
            'Total ${formatQty(ing.totalStock, ing.unit)} dalam ${list.length} batch',
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
            'Stok akan muncul setelah barang diterima.',
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

  Widget _buildBatchCard(Batch b, Ingredient ing) {
    final days = b.daysLeft;
    final expired = b.isExpired;
    final warning = expired || b.isExpiringSoon;

    final body = Padding(
      padding: const EdgeInsets.fromLTRB(15, 14, 15, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                b.label,
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
          _batchRow('Stok', formatQty(b.quantity, ing.unit)),
          const SizedBox(height: 4),
          _batchRow('Baik Sebelum', formatDateId(b.expiryDate)),
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
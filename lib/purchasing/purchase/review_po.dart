import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../partials/colors.dart';
import 'detail_po.dart' show PoBadge, PoStatus;

/// Halaman Review Purchase Order (langkah 2 setelah Buat PO).
/// Satu kartu per supplier (= satu PO, status Draft). Qty & harga bisa diedit,
/// total dihitung ulang otomatis. Hanya tampilan; kirim ke API dikerjakan FE.

// ============================ MODEL ============================
class PoReviewItem {
  final String name;
  final String unit;
  double qty;
  int price; // harga per satuan, rupiah

  PoReviewItem({
    required this.name,
    required this.unit,
    required this.qty,
    this.price = 0, // TODO FE: isi otomatis dari harga terakhir supplier
  });

  int get subtotal => (qty * price).round();
}

class PoReviewGroup {
  final String supplier;
  final List<PoReviewItem> items;

  PoReviewGroup({required this.supplier, required this.items});

  int get total => items.fold(0, (sum, e) => sum + e.subtotal);
}

String formatRupiah(int v) {
  final s = v.toString();
  final b = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) b.write('.');
    b.write(s[i]);
  }
  return 'Rp $b';
}

String formatQty(double q) => q % 1 == 0 ? q.toInt().toString() : q.toString();

// ============================ PAGE ============================
class ReviewPoPage extends StatefulWidget {
  final List<PoReviewGroup> groups;

  const ReviewPoPage({super.key, required this.groups});

  @override
  State<ReviewPoPage> createState() => _ReviewPoPageState();
}

class _ReviewPoPageState extends State<ReviewPoPage> {
  int get _grandTotal => widget.groups.fold(0, (s, g) => s + g.total);

  /// Tombol Ajukan aktif hanya jika semua qty & harga sudah terisi.
  bool get _valid => widget.groups.every(
        (g) => g.items.every((i) => i.qty > 0 && i.price > 0),
      );

  void _refresh() => setState(() {});

  void _ajukan() {
    // TODO FE: kirim semua PO (status Draft -> Menunggu Review Owner) ke API
    Navigator.popUntil(context, (r) => r.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const _TopBar(title: 'Review Purchase Order'),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(25, 20, 25, 20),
              child: Column(
                children: [
                  const _WarnBanner(
                    text:
                        'Pastikan jumlah setiap item sudah sesuai sebelum diajukan kepada Owner.',
                  ),
                  const SizedBox(height: 14),
                  for (final g in widget.groups) ...[
                    _SupplierCard(group: g, onChanged: _refresh),
                    const SizedBox(height: 14),
                  ],
                ],
              ),
            ),
          ),
          // ---------- Footer total + tombol ----------
          Container(
            padding: EdgeInsets.fromLTRB(
              25,
              12,
              25,
              MediaQuery.of(context).padding.bottom + 16,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: AppColors.cardBorder, width: 1),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total (${widget.groups.length} PO)',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        color: AppColors.brownDark,
                      ),
                    ),
                    Text(
                      formatRupiah(_grandTotal),
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.brownDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _PrimaryButton(
                  label: 'Ajukan Purchase Order',
                  enabled: _valid,
                  onTap: _ajukan,
                ),
                if (!_valid) ...[
                  const SizedBox(height: 6),
                  const Text(
                    'Lengkapi jumlah dan harga semua item',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 10,
                      color: AppColors.red,
                    ),
                  ),
                ],
              ],
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

// ============================ BANNER ============================
class _WarnBanner extends StatelessWidget {
  final String text;

  const _WarnBanner({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardWarnBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.cardWarnBorder, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded,
              color: AppColors.orange, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
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

// ============================ KARTU SUPPLIER ============================
class _SupplierCard extends StatelessWidget {
  final PoReviewGroup group;
  final VoidCallback onChanged;

  const _SupplierCard({required this.group, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
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
                  group.supplier,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.brownDark,
                  ),
                ),
              ),
              const PoBadge(status: PoStatus.draft),
            ],
          ),
          const SizedBox(height: 10),
          for (final item in group.items) ...[
            _ItemBlock(item: item, onChanged: onChanged),
            const SizedBox(height: 10),
          ],
          const _DashedLine(),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total PO',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  color: AppColors.brownDark,
                ),
              ),
              Text(
                formatRupiah(group.total),
                style: const TextStyle(
                  fontFamily: 'Poppins',
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
  final PoReviewItem item;
  final VoidCallback onChanged;

  const _ItemBlock({required this.item, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.name,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.brown,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            _NumberField(
              width: 82,
              initial: formatQty(item.qty),
              suffix: item.unit,
              allowDecimal: true,
              onChanged: (v) {
                item.qty = double.tryParse(v.replaceAll(',', '.')) ?? 0;
                onChanged();
              },
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 6),
              child: Text(
                'x',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11,
                  color: AppColors.subText,
                ),
              ),
            ),
            _NumberField(
              width: 108,
              initial: item.price == 0 ? '' : item.price.toString(),
              prefix: 'Rp ',
              hint: '0',
              onChanged: (v) {
                item.price = int.tryParse(v) ?? 0;
                onChanged();
              },
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    formatRupiah(item.subtotal),
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.brownDark,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _NumberField extends StatelessWidget {
  final double width;
  final String initial;
  final String? suffix;
  final String? prefix;
  final String? hint;
  final bool allowDecimal;
  final ValueChanged<String> onChanged;

  const _NumberField({
    required this.width,
    required this.initial,
    required this.onChanged,
    this.suffix,
    this.prefix,
    this.hint,
    this.allowDecimal = false,
  });

  @override
  Widget build(BuildContext context) {
    const TextStyle style = TextStyle(
      fontFamily: 'Poppins',
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: AppColors.brownDark,
    );

    return Container(
      width: width,
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.brown, width: 1),
      ),
      child: TextFormField(
        initialValue: initial,
        keyboardType: TextInputType.numberWithOptions(decimal: allowDecimal),
        inputFormatters: [
          FilteringTextInputFormatter.allow(
            RegExp(allowDecimal ? r'[0-9.,]' : r'[0-9]'),
          ),
        ],
        style: style,
        onChanged: onChanged,
        decoration: InputDecoration(
          isDense: true,
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
          prefixText: prefix,
          prefixStyle: style,
          suffixText: suffix,
          suffixStyle: style.copyWith(color: AppColors.subText),
          hintText: hint,
          hintStyle: style.copyWith(color: AppColors.subText.withOpacity(0.5)),
        ),
      ),
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
  final bool enabled;
  final VoidCallback onTap;

  const _PrimaryButton({
    required this.label,
    required this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: double.infinity,
        height: 48,
        decoration: BoxDecoration(
          color: enabled ? AppColors.orange : AppColors.tilePeach,
          borderRadius: BorderRadius.circular(6),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: enabled ? Colors.white : AppColors.brown,
          ),
        ),
      ),
    );
  }
}
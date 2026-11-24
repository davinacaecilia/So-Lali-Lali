import 'package:flutter/material.dart';

import '../partials/colors.dart';
import '../partials/header.dart';
import '../partials/navbar.dart';
import 'buat_po.dart';
import 'detail_po.dart';

// ============================ MODEL (DUMMY) ============================
class _PurchaseOrder {
  final String code;
  final String supplier;
  final String summary;
  final PoStatus status;

  const _PurchaseOrder({
    required this.code,
    required this.supplier,
    required this.summary,
    required this.status,
  });
}

const List<_PurchaseOrder> _dummyPo = [
  _PurchaseOrder(
    code: 'PO-0016',
    supplier: 'PT Abdi Jaya',
    summary: '1 item · Rp 90.000',
    status: PoStatus.draft,
  ),
  _PurchaseOrder(
    code: 'PO-0016',
    supplier: 'PT Abdi Jaya',
    summary: '1 item · Rp 90.000',
    status: PoStatus.menunggu,
  ),
  _PurchaseOrder(
    code: 'PO-0016',
    supplier: 'PT Abdi Jaya',
    summary: '1 item · Rp 90.000',
    status: PoStatus.diproses,
  ),
  _PurchaseOrder(
    code: 'PO-0016',
    supplier: 'PT Abdi Jaya',
    summary: '1 item · Rp 90.000',
    status: PoStatus.ditolak,
  ),
  _PurchaseOrder(
    code: 'PO-0016',
    supplier: 'PT Abdi Jaya',
    summary: '1 item · Rp 90.000',
    status: PoStatus.diterima,
  ),
];

// Filter chip: null = Semua
const List<MapEntry<String, PoStatus?>> _filters = [
  MapEntry('Semua', null),
  MapEntry('Draft', PoStatus.draft),
  MapEntry('Menunggu', PoStatus.menunggu),
  MapEntry('Diproses', PoStatus.diproses),
];

// ============================ PAGE ============================
class PurchasePage extends StatefulWidget {
  const PurchasePage({super.key});

  @override
  State<PurchasePage> createState() => _PurchasePageState();
}

class _PurchasePageState extends State<PurchasePage> {
  int _selectedFilter = 0;

  @override
  Widget build(BuildContext context) {
    final PoStatus? filter = _filters[_selectedFilter].value;
    final List<_PurchaseOrder> items = filter == null
        ? _dummyPo
        : _dummyPo.where((e) => e.status == filter).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const AppHeader(),
          Expanded(
            child: Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(25, 24, 25, 100),
                  child: Column(
                    children: [
                      const _SearchField(hint: 'Cari nomor PO'),
                      const SizedBox(height: 12),
                      _FilterChips(
                        selected: _selectedFilter,
                        onChanged: (i) => setState(() => _selectedFilter = i),
                      ),
                      const SizedBox(height: 14),
                      for (final po in items) ...[
                        _PoCard(po: po),
                        const SizedBox(height: 14),
                      ],
                    ],
                  ),
                ),
                // Tombol tambah PO
                Positioned(
                  right: 24,
                  bottom: 22,
                  child: _AddButton(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const BuatPoPage.manual()),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const AppBottomNav(currentIndex: 2),
        ],
      ),
    );
  }
}

// ============================ SEARCH ============================
class _SearchField extends StatelessWidget {
  final String hint;

  const _SearchField({required this.hint});

  @override
  Widget build(BuildContext context) {
    return Container(
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
                fontFamily: kFont,
                fontSize: 14,
                color: AppColors.brownDark,
              ),
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: hint,
                hintStyle: TextStyle(
                  fontFamily: kFont,
                  fontSize: 14,
                  color: AppColors.subText.withOpacity(0.7),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================ FILTER CHIPS ============================
class _FilterChips extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onChanged;

  const _FilterChips({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 34,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (_, i) {
          final bool active = i == selected;
          return GestureDetector(
            onTap: () => onChanged(i),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: active ? AppColors.primary : AppColors.filterItemBg,
                borderRadius: BorderRadius.circular(6),
              ),
              alignment: Alignment.center,
              child: Text(
                _filters[i].key,
                style: TextStyle(
                  fontFamily: kFont,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: active ? Colors.white : AppColors.brown,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ============================ KARTU PO ============================
class _PoCard extends StatelessWidget {
  final _PurchaseOrder po;

  const _PoCard({required this.po});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DetailPoPage(
                code: po.code,
                supplier: po.supplier,
                status: po.status,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 14, 15, 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.cardBorder, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        po.code,
                        style: const TextStyle(
                          fontFamily: kFont,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.brown,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ),
                  PoBadge(status: po.status),
                ],
              ),
              Text(
                po.supplier,
                style: const TextStyle(
                  fontFamily: kFont,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.brownDark,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                po.summary,
                style: const TextStyle(
                  fontFamily: kFont,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: AppColors.subText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================ TOMBOL TAMBAH ============================
class _AddButton extends StatelessWidget {
  final VoidCallback onTap;

  const _AddButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.orange,
      borderRadius: BorderRadius.circular(8),
      elevation: 3,
      shadowColor: Colors.black38,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: const SizedBox(
          width: 54,
          height: 54,
          child: Icon(Icons.add, color: Colors.white, size: 28),
        ),
      ),
    );
  }
}
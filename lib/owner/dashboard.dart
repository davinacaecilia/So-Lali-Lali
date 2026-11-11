import 'package:flutter/material.dart';

import 'partials/bottom_nav.dart';
import 'partials/colors.dart';
import 'partials/header.dart';

class DashboardOwnerPage extends StatefulWidget {
  const DashboardOwnerPage({super.key});

  @override
  State<DashboardOwnerPage> createState() => _DashboardOwnerPageState();
}

class _DashboardOwnerPageState extends State<DashboardOwnerPage> {
  int _navIndex = 0;
  String _filter = 'Food Cost';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const DashboardHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(25, 18, 25, 24),
              child: Column(
                children: [
                  const _TotalStockCard(),
                  const SizedBox(height: 20),
                  const Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          title: 'Food Cost',
                          value: '32,4%',
                          note: '+ 3,12% dari bulan lalu',
                          noteColor: AppColors.green,
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: _StatCard(
                          title: 'Waste',
                          value: 'Rp 12 jt',
                          note: '- 3,12% dari bulan lalu',
                          noteColor: AppColors.red,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          title: 'Variance',
                          value: '-1,8%',
                          note: 'Opname terakhir',
                          noteColor: AppColors.brownDark,
                          noteBold: true,
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: _StatCard(
                          title: 'Stok Menipis',
                          value: '10 bahan',
                          note: 'Perlu Restock',
                          noteColor: AppColors.red,
                          noteBold: true,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildPendingApproval(),
                  const SizedBox(height: 20),
                  _buildWeeklySummary(),
                ],
              ),
            ),
          ),
          OwnerBottomNav(
            currentIndex: _navIndex,
            onTap: (i) => setState(() => _navIndex = i),
          ),
        ],
      ),
    );
  }

  // ---------------- MENUNGGU PERSETUJUAN ----------------
  Widget _buildPendingApproval() {
    return const _OutlinedCard(
      padding: EdgeInsets.fromLTRB(22, 18, 22, 14),
      child: Column(
        children: [
          _SectionHeader(title: 'Menunggu Persetujuan'),
          SizedBox(height: 14),
          _ApprovalItem(icon: Icons.sell_outlined, title: 'PO #123'),
          _ApprovalItem(icon: Icons.assignment_outlined, title: 'Stok Opname'),
          _ApprovalItem(icon: Icons.sell_outlined, title: 'PO #123'),
          _ApprovalItem(icon: Icons.assignment_outlined, title: 'Stok Opname'),
        ],
      ),
    );
  }

  // ---------------- RINGKASAN MINGGUAN ----------------
  Widget _buildWeeklySummary() {
    const days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    return _OutlinedCard(
      padding: const EdgeInsets.fromLTRB(23, 20, 23, 16),
      child: Column(
        children: [
          const _SectionHeader(title: 'Ringkasan Mingguan'),
          const SizedBox(height: 12),
          Container(
            height: 30,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: AppColors.brown, width: 0.8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _filter,
                isExpanded: true,
                isDense: true,
                icon: const Icon(Icons.keyboard_arrow_down_rounded,
                    color: AppColors.brown, size: 20),
                style: const TextStyle(
                  color: AppColors.brown,
                  fontSize: 13,
                  fontFamily: kFont,
                ),
                items: const ['Food Cost', 'Waste', 'Variance']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(() => _filter = v ?? _filter),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(days.length, (i) {
              final isLast = i == days.length - 1;
              return Column(
                children: [
                  Container(
                    width: 36,
                    height: 58,
                    decoration: BoxDecoration(
                      color: isLast ? AppColors.barDark : AppColors.barLight,
                      borderRadius: BorderRadius.circular(7),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    days[i],
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.brownDark,
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}

// =====================================================
// TOTAL NILAI STOK
// =====================================================
class _TotalStockCard extends StatelessWidget {
  const _TotalStockCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
      decoration: BoxDecoration(
        color: AppColors.brown,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(Icons.inventory_2_rounded, color: Colors.white, size: 70),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Total Nilai Stok',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Rp 12.000.000',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    '+ 3,12% dari minggu lalu',
                    style: TextStyle(
                      color: AppColors.brownDark,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
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

// =====================================================
// KARTU STATISTIK (Food Cost, Waste, Variance, Stok Menipis)
// =====================================================
class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String note;
  final Color noteColor;
  final bool noteBold;

  const _StatCard({
    required this.title,
    required this.value,
    required this.note,
    required this.noteColor,
    this.noteBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 124,
      padding: const EdgeInsets.fromLTRB(25, 20, 12, 12),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              color: AppColors.brownDark,
            ),
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w600,
                color: AppColors.orange,
                height: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            note,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              color: noteColor,
              fontWeight: noteBold ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

// =====================================================
// KOMPONEN UMUM
// =====================================================
class _OutlinedCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const _OutlinedCard({required this.child, required this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: const Color(0xFFFFFAF6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: child,
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.brown,
          ),
        ),
        GestureDetector(
          onTap: () {},
          child: const Text(
            'Lihat Semua',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.orange,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _ApprovalItem extends StatelessWidget {
  final IconData icon;
  final String title;

  const _ApprovalItem({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.iconBox,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.brown, size: 22),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                    height: 1.2,
                  ),
                ),
                const Text(
                  'oleh Enjeli',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textDark,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const Text(
            '24 Nov 2026\n13.59',
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.brown,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}
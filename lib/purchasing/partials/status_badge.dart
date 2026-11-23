import 'package:flutter/material.dart';
import 'colors.dart';

enum AppStatus { diproses, menunggu, disetujui, ditolak, selesai }

/// Badge status yang bisa dipakai ulang di halaman lain.
class StatusBadge extends StatelessWidget {
  final AppStatus status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    late final String label;
    late final Color bg;
    late final Color fg;

    switch (status) {
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
      case AppStatus.disetujui:
        label = 'Disetujui';
        bg = AppColors.disetujuiBg;
        fg = AppColors.disetujuiText;
        break;
      case AppStatus.selesai:
        label = 'Selesai';
        bg = AppColors.disetujuiBg;
        fg = AppColors.disetujuiText;
        break;
      case AppStatus.selesai:
        label = 'Selesai';
        bg = AppColors.disetujuiBg;
        fg = AppColors.disetujuiText;
        break;
      case AppStatus.ditolak:
        label = 'Ditolak';
        bg = AppColors.ditolakBg;
        fg = AppColors.ditolakText;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: fg,
        ),
      ),
    );
  }
}
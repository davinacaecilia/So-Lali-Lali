import 'package:flutter/material.dart';
import 'colors.dart';

/// Header global: logo, judul, subjudul, notifikasi, dan avatar.
class AppHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final String logoAsset;
  final String avatarAsset;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onAvatarTap;

  const AppHeader({
    super.key,
    this.title = 'SO LALI LALI',
    this.subtitle = 'Staff Purchasing',
    this.logoAsset = 'assets/images/logo.png',
    this.avatarAsset = 'assets/images/avatar.png',
    this.onNotificationTap,
    this.onAvatarTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.headerBg,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 14,
        bottom: 14,
        left: 28,
        right: 20,
      ),
      child: Row(
        children: [
          // Logo
          SizedBox(
            width: 84,
            height: 56,
            child: Image.asset(
              logoAsset,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Container(
                decoration: BoxDecoration(
                  color: AppColors.iconTile,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.local_cafe,
                    color: AppColors.brown, size: 30),
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.brown,
                    height: 1.2,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: AppColors.brown,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
          // Notification
          InkWell(
            onTap: onNotificationTap,
            customBorder: const CircleBorder(),
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.cardBorder, width: 1.2),
              ),
              child: const Icon(
                Icons.notifications_none_rounded,
                color: AppColors.iconBrown,
                size: 26,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Avatar
          InkWell(
            onTap: onAvatarTap,
            customBorder: const CircleBorder(),
            child: ClipOval(
              child: SizedBox(
                width: 46,
                height: 46,
                child: Image.asset(
                  avatarAsset,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: AppColors.iconTile,
                    child: const Icon(Icons.person, color: AppColors.brown),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'colors.dart';

void _infoSheet(BuildContext context, IconData icon, String title, String body) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (_) => Padding(
      padding: EdgeInsets.fromLTRB(
          24, 24, 24, MediaQuery.of(context).padding.bottom + 32),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 40, color: AppColors.iconBrown),
        const SizedBox(height: 12),
        Text(title,
            style: const TextStyle(
                fontFamily: kFont,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.brownDark)),
        const SizedBox(height: 4),
        Text(body,
            style: const TextStyle(
                fontFamily: kFont, fontSize: 12, color: AppColors.subText)),
      ]),
    ),
  );
}

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
                    fontFamily: kFont,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.brown,
                    height: 1.2,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontFamily: kFont,
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
            onTap: onNotificationTap ??
                () => _infoSheet(context, Icons.notifications_none_rounded,
                    'Notifikasi', 'Belum ada notifikasi baru.'),
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
            onTap: onAvatarTap ??
                () => _infoSheet(
                    context, Icons.person_outline, title, subtitle),
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
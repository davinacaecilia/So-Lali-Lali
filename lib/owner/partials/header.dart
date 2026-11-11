import 'package:flutter/material.dart';
import 'colors.dart';

class DashboardHeader extends StatelessWidget {
  const DashboardHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.headerBg,
        boxShadow: [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(26, 14, 18, 14),
          child: Row(
            children: [
              // Logo (ganti dengan Image.asset('assets/logo.png') milikmu)
              SizedBox(
                width: 84,
                height: 56,
                child: Image.asset(
                  'assets/logo.png',
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Container(
                    decoration: BoxDecoration(
                      color: AppColors.iconBox,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.local_cafe,
                        color: AppColors.brown, size: 30),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SO LALI LALI',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppColors.brown,
                        height: 1.2,
                      ),
                    ),
                    Text(
                      'Dashboard Owner',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFFA9713A),
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              // Tombol notifikasi
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.background,
                  border: Border.all(color: const Color(0xFFD9CDBA)),
                ),
                child: const Icon(Icons.notifications_none_rounded,
                    color: AppColors.brownDark, size: 24),
              ),
              const SizedBox(width: 8),
              // Foto profil (ganti dengan Image.asset / NetworkImage milikmu)
              ClipOval(
                child: SizedBox(
                  width: 46,
                  height: 46,
                  child: Image.asset(
                    'assets/avatar.png',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: const Color(0xFFD9CDBA),
                      child: const Icon(Icons.person,
                          color: Colors.white, size: 28),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
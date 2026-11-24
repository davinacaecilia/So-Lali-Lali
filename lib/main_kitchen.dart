import 'package:flutter/material.dart';

import 'kitchen/kitchen_screen.dart';

/// Entry point KHUSUS untuk preview halaman Kitchen tanpa login.
/// Jalankan: flutter run -t lib/main_kitchen.dart
/// (Hapus file ini sebelum push kalau backend sudah menyambungkan rute-nya.)
void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'So Lali Lali - Kitchen',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFE59E2C)),
      ),
      home: const KitchenScreen(),
    ),
  );
}

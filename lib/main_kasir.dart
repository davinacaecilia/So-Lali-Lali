import 'package:flutter/material.dart';

import 'kasir/kasir_screen.dart';

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'So Lali Lali - Kasir',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFE59E2C)),
      ),
      home: const KasirScreen(),
    ),
  );
}
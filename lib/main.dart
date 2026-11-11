import 'package:flutter/material.dart';

import 'screen/splash.dart';
import 'auth/login.dart';
import 'auth/daftar.dart';
import 'auth/lupa_password.dart';
import 'auth/verifikasi_akun.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SO LALI-LALI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2F4366), // navy dari style guide
        ),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/daftar': (context) => const RegisterScreen(),
        '/lupa-password': (context) => const ForgotPasswordScreen(),
        '/verifikasi-akun': (context) => const VerifyEmailScreen(),
      },
    );
  }
}
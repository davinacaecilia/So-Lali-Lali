import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'owner/dashboard.dart';
import 'kitchen/kitchen_screen.dart';
import 'kasir/kasir_screen.dart';
import 'owner/partials/colors.dart';

import 'screen/splash.dart';
import 'auth/login.dart';
import 'auth/daftar.dart';
import 'auth/lupa_password.dart';
import 'auth/verifikasi_akun.dart';

import 'screen/home.dart';   // tambahan

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
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
        fontFamily: kFont,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2F4366), // navy dari style guide
        ),
        scaffoldBackgroundColor: AppColors.background,
        useMaterial3: true,
      ),
      // home: const DashboardOwnerPage(),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/daftar': (context) => const RegisterScreen(),
        '/lupa-password': (context) => const ForgotPasswordScreen(),
        '/verifikasi-akun': (context) => const VerifyEmailScreen(),
        '/owner': (context) => const DashboardOwnerPage(),   // tambahan
        '/kasir': (context) => const KasirScreen(),
        '/kitchen': (context) => const KitchenScreen(),
        '/home': (context) => const HomeFrontendScreen(),    // tambahan (placeholder role lain)
      },
    );
  }
}
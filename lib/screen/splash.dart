import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Splash screen SO LALI-LALI
///
/// Urutan animasi:
/// 1. Ornamen atas dan bawah "membuka" dari tengah ke tepi layar
/// 2. Logo muncul (fade + membesar + naik) dengan cahaya lembut di belakangnya
/// 3. Tagline muncul (fade + naik + huruf merapat)
/// 4. Titik loading berdenyut, logo melayang pelan
/// 5. Pindah ke halaman berikutnya
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  /// Nama route tujuan setelah splash selesai (didaftarkan di main.dart).
  static const String nextRoute = '/login';

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // Durasi total animasi (ms). Ubah di sini kalau mau lebih cepat/lambat.
  static const int _totalMs = 5200;

  // Bagian ornamen yang tetap terlihat setelah animasi selesai.
  // 0.07 berarti sekitar 7% tinggi layar di bagian atas dan bawah.
  static const double _visibleOrnamentFactor = 0.19;

  // Rasio asli file PNG (1236 x 1602). Jangan stretch ke ukuran layar.
  static const double _ornamentAspectRatio = 1602 / 1236;

  // Warna dari style guide
  static const Color _orange = Color(0xFFE59E2C);
  static const Color _yellow = Color(0xFFF3D58D);
  static const Color _cream = Color(0xFFFFF1D2);
  static const Color _brown = Color(0xFF8B3B08);
  static const Color _navy = Color(0xFF2F4366);

  late final AnimationController _controller; // timeline utama
  late final AnimationController _loop; // efek melayang + titik loading

  late final Animation<double> _open;
  late final Animation<double> _logoFade;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoRise;
  late final Animation<double> _glow;
  late final Animation<double> _textFade;
  late final Animation<double> _textSpacing;

  bool _started = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: _totalMs),
    );
    _loop = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat();

    CurvedAnimation curve(double begin, double end, Curve c) =>
        CurvedAnimation(parent: _controller, curve: Interval(begin, end, curve: c));

    // 5% - 40%: ornamen membuka
    _open = curve(0.05, 0.40, Curves.easeInOutCubic);

    // 35% - 65%: logo + cahaya
    _logoFade = curve(0.35, 0.55, Curves.easeOut);
    _logoScale = Tween<double>(begin: 0.7, end: 1.0)
        .animate(curve(0.35, 0.65, Curves.easeOutBack));
    _logoRise = Tween<double>(begin: 24, end: 0)
        .animate(curve(0.35, 0.65, Curves.easeOutCubic));
    _glow = curve(0.35, 0.75, Curves.easeOut);

    // 60% - 90%: tagline
    _textFade = curve(0.60, 0.80, Curves.easeOut);
    _textSpacing = Tween<double>(begin: 3.0, end: 0.3)
        .animate(curve(0.60, 0.90, Curves.easeOutCubic));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    _preloadAndStart();
  }

  /// Muat semua gambar dulu supaya animasi tidak patah-patah.
  Future<void> _preloadAndStart() async {
    await Future.wait([
      precacheImage(const AssetImage('assets/images/logo.png'), context),
      precacheImage(const AssetImage('assets/images/ornament-top.png'), context),
      precacheImage(const AssetImage('assets/images/ornament-bottom.png'), context),
    ]);
    if (!mounted) return;
    await _controller.forward();
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(SplashScreen.nextRoute);
  }

  @override
  void dispose() {
    _controller.dispose();
    _loop.dispose();
    super.dispose();
  }

  Widget _loadingDots() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        final phase = (_loop.value - i * 0.18) % 1.0;
        final o = 0.3 + 0.7 * (0.5 + 0.5 * math.sin(phase * 2 * math.pi));
        return Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _orange.withOpacity(o),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    // Pertahankan rasio asli PNG. Ornamen hanya digeser, bukan dikecilkan.
    final ornamentHeight = width * _ornamentAspectRatio;
    final visibleOrnamentHeight = height * _visibleOrnamentFactor;
    final ornamentTravel =
        (ornamentHeight - visibleOrnamentHeight).clamp(0.0, ornamentHeight);

    return Scaffold(
      body: AnimatedBuilder(
        animation: Listenable.merge([_controller, _loop]),
        builder: (context, _) {
          // Logo melayang pelan setelah muncul
          final float =
              math.sin(_loop.value * 2 * math.pi) * 5 * _logoFade.value;

          return Container(
            width: double.infinity,
            height: double.infinity,
            // Putih di atas, memudar ke krem di bawah (sesuai Figma)
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.white, _cream],
                stops: [0.5, 0.917],
              ),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Cahaya lembut di belakang logo
                Center(
                  child: Opacity(
                    opacity: _glow.value.clamp(0.0, 1.0),
                    child: Container(
                      width: width * 1.0,
                      height: width * 1.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            _yellow.withOpacity(0.55),
                            _yellow.withOpacity(0.0),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Logo + tagline + titik loading
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Opacity(
                        opacity: _logoFade.value.clamp(0.0, 1.0),
                        child: Transform.translate(
                          offset: Offset(0, _logoRise.value + float),
                          child: Transform.scale(
                            scale: _logoScale.value,
                            child: Image.asset(
                              'assets/images/logo.png',
                              width: width * 0.72,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Opacity(
                        opacity: _textFade.value.clamp(0.0, 1.0),
                        child: Transform.translate(
                          offset: Offset(0, 16 * (1 - _textFade.value)),
                          child: Text(
                            'Supply Organizer, Laporan & Inventory',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              letterSpacing: _textSpacing.value,
                              color: _brown,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      Opacity(
                        opacity: _textFade.value.clamp(0.0, 1.0),
                        child: _loadingDots(),
                      ),
                    ],
                  ),
                ),

                // Penutup navy: memudar saat ornamen membuka
                Positioned.fill(
                  child: IgnorePointer(
                    child: Opacity(
                      opacity: (1 - _open.value).clamp(0.0, 1.0),
                      child: const ColoredBox(color: _navy),
                    ),
                  ),
                ),

                // Ornamen atas: bergerak ke atas, tetapi sisakan lengkungan
                // navy/emas di tepi layar seperti desain yang diinginkan.
                Positioned(
                  top: -ornamentTravel * _open.value,
                  left: 2,
                  right: -2,
                  child: Image.asset(
                    'assets/images/ornament-top.png',
                    width: width,
                    fit: BoxFit.fitWidth,
                  ),
                ),

                // Ornamen bawah: bergerak ke bawah dengan jarak yang sama.
                // Bagian lengkungan tetap terlihat di tepi bawah layar.
                Positioned(
                  bottom: -ornamentTravel * _open.value,
                  left: -2,
                  right: 2,
                  child: Image.asset(
                    'assets/images/ornament-bottom.png',
                    width: width,
                    fit: BoxFit.fitWidth,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/auth_service.dart';
import '../services/otp_service.dart';
import 'auth_widgets.dart';

class VerifyEmailScreen extends StatefulWidget {
  final String email;
  const VerifyEmailScreen({super.key, this.email = ''});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  static const _resendSeconds = 30;

  final _otpControllers = List.generate(4, (_) => TextEditingController());
  final _otpFocusNodes = List.generate(4, (_) => FocusNode());

  Timer? _timer;
  int _secondsLeft = _resendSeconds;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _startTimer(); // kode baru saja dikirim dari halaman Daftar
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final controller in _otpControllers) {
      controller.dispose();
    }
    for (final node in _otpFocusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _secondsLeft = _resendSeconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_secondsLeft <= 1) {
        t.cancel();
        setState(() => _secondsLeft = 0);
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  String get _timerText {
    final m = (_secondsLeft ~/ 60).toString().padLeft(2, '0');
    final s = (_secondsLeft % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Future<void> _resend() async {
    if (_sending || _secondsLeft > 0) return;
    setState(() => _sending = true);
    try {
      await OtpService.instance.send(widget.email);
      for (final c in _otpControllers) {
        c.clear();
      }
      _otpFocusNodes.first.requestFocus();
      _startTimer();
      if (mounted) showAuthMessage(context, 'Kode baru sudah dikirim.');
    } on AuthException catch (e) {
      if (mounted) showAuthMessage(context, e.message);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  void _verify() {
    final otp = _otpControllers.map((c) => c.text).join();
    if (otp.length != 4) {
      showAuthMessage(context, 'Masukkan 4 digit kode verifikasi.');
      return;
    }

    final error = OtpService.instance.verify(widget.email, otp);
    if (error != null) {
      showAuthMessage(context, error);
      return;
    }

    // Kode benar: kembali ke halaman Daftar dengan hasil true
    Navigator.pop(context, true);
  }

  Widget _buildOtpBox(int index) {
    return SizedBox(
      width: 49,
      height: 53,
      child: TextField(
        controller: _otpControllers[index],
        focusNode: _otpFocusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: GoogleFonts.plusJakartaSans(
          color: authBrown,
          fontSize: 19,
          fontWeight: FontWeight.w700,
        ),
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: index < 2 ? const Color(0xFFFFE8BF) : Colors.white,
          contentPadding: EdgeInsets.zero,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: authBrown.withOpacity(0.6)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: authBrown.withOpacity(0.6)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: authOrange, width: 1.5),
          ),
        ),
        onChanged: (value) {
          if (value.isNotEmpty && index < 3) {
            _otpFocusNodes[index + 1].requestFocus();
          } else if (value.isEmpty && index > 0) {
            _otpFocusNodes[index - 1].requestFocus();
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final canResend = _secondsLeft == 0 && !_sending;

    return AuthPageBackground(
      child: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(25, 145, 25, 24),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight - 169),
            child: Column(
              children: [
                AuthLogoHeader(
                  title: 'Verifikasi Email',
                  subtitle:
                  'Masukkan kode yang dikirim ke email\n${widget.email}',
                  logoWidth: 180,
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    4,
                        (index) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: _buildOtpBox(index),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  _secondsLeft > 0
                      ? 'Kirim ulang kode dalam $_timerText'
                      : 'Tidak menerima kode?',
                  style: GoogleFonts.plusJakartaSans(
                    color: authBrown,
                    fontSize: 11,
                  ),
                ),
                TextButton(
                  onPressed: canResend ? _resend : null,
                  child: Text(
                    'Kirim ulang kode',
                    style: GoogleFonts.plusJakartaSans(
                      color: authBrown.withOpacity(canResend ? 1 : 0.4),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                const SizedBox(height: 34),
                AuthPrimaryButton(
                  text: 'Verifikasi',
                  onPressed: _verify,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'auth_widgets.dart';
import 'login.dart';

class VerifyEmailScreen extends StatefulWidget {
  final String email;
  const VerifyEmailScreen({super.key, this.email = ''});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  final _otpControllers = List.generate(4, (_) => TextEditingController());
  final _otpFocusNodes = List.generate(4, (_) => FocusNode());

  @override
  void dispose() {
    for (final controller in _otpControllers) {
      controller.dispose();
    }
    for (final node in _otpFocusNodes) {
      node.dispose();
    }
    super.dispose();
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
                      'Masukkan kode simulasi yang ditampilkan untuk email\n${widget.email}',
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
                  'Kirim ulang kode dalam 10:00',
                  style: GoogleFonts.plusJakartaSans(
                    color: authBrown,
                    fontSize: 11,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    for (final controller in _otpControllers) {
                      controller.clear();
                    }
                    _otpFocusNodes.first.requestFocus();
                    showAuthMessage(context, 'Kolom kode dikosongkan.');
                  },
                  child: Text(
                    'Kirim ulang kode',
                    style: GoogleFonts.plusJakartaSans(
                      color: authBrown,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                const SizedBox(height: 34),
                AuthPrimaryButton(
                  text: 'Verifikasi',
                  onPressed: () {
                    final otp = _otpControllers.map((c) => c.text).join();
                    if (otp.length != 4) {
                      showAuthMessage(context, 'Masukkan 4 digit kode verifikasi.');
                      return;
                    }

                    // Simulasi verifikasi frontend: kembali ke halaman Login.
                    showAuthMessage(context, 'Verifikasi berhasil (simulasi).');
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

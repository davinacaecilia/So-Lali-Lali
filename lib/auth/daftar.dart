import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'auth_widgets.dart';
import 'login.dart';
import 'verifikasi_akun.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _businessController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _hidePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _businessController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AuthPageBackground(
      child: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(25, 100, 25, 22),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight - 122),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const AuthLogoHeader(
                    title: 'Daftar',
                    subtitle: 'Daftarkan usaha F&B Anda untuk mulai\nmengelola stok bahan baku.',
                  ),
                  const SizedBox(height: 20),
                  AuthTextField(
                    label: 'Nama Lengkap',
                    controller: _nameController,
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'Nama lengkap wajib diisi'
                        : null,
                  ),
                  const SizedBox(height: 10),
                  AuthTextField(
                    label: 'Nama Usaha',
                    controller: _businessController,
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'Nama usaha wajib diisi'
                        : null,
                  ),
                  const SizedBox(height: 10),
                  AuthTextField(
                    label: 'Email',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) => v == null || !v.contains('@')
                        ? 'Masukkan email yang valid'
                        : null,
                  ),
                  const SizedBox(height: 10),
                  AuthTextField(
                    label: 'Password',
                    controller: _passwordController,
                    obscureText: _hidePassword,
                    suffixIcon: IconButton(
                      onPressed: () =>
                          setState(() => _hidePassword = !_hidePassword),
                      icon: Icon(
                        _hidePassword ? Icons.visibility_off : Icons.visibility,
                        size: 19,
                        color: authBrown.withOpacity(0.7),
                      ),
                    ),
                    validator: (v) => v == null || v.length < 6
                        ? 'Password minimal 6 karakter'
                        : null,
                  ),
                  const SizedBox(height: 18),
                  AuthPrimaryButton(
                    text: 'Daftar',
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        // Simulasi daftar frontend: lanjut ke halaman verifikasi.
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => VerifyEmailScreen(
                              email: _emailController.text.trim(),
                            ),
                          ),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  Text('atau', style: GoogleFonts.plusJakartaSans(fontSize: 11)),
                  const SizedBox(height: 12),
                  AuthGoogleButton(
                    onPressed: () => showAuthMessage(
                      context,
                      'Daftar dengan Google belum tersedia pada demo frontend.',
                    ),
                  ),
                  const SizedBox(height: 13),
                  AuthBottomLink(
                    text: 'Sudah memiliki akun? ',
                    action: 'Masuk Sekarang',
                    onTap: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

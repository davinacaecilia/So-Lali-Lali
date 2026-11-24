import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'auth_widgets.dart';
import 'daftar.dart';
import 'lupa_password.dart';
import '/screen/home.dart';

import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _hidePassword = true;

  bool _loading = false;

  Future<void> _login() async {
    if (_loading || _googleLoading) return;
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final role = await AuthService.instance.login(
        _emailController.text.trim(),
        _passwordController.text,
      );
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
        context,
        AuthService.routeForRole(role),
            (_) => false,
      );
    } on AuthException catch (e) {
      if (mounted) showAuthMessage(context, e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  bool _googleLoading = false;

  Future<void> _loginWithGoogle() async {
    if (_googleLoading) return;
    setState(() => _googleLoading = true);
    try {
      final role = await AuthService.instance.signInWithGoogle();
      if (role == null || !mounted) return; // dibatalkan user
      Navigator.pushNamedAndRemoveUntil(
        context,
        AuthService.routeForRole(role),
            (_) => false,
      );
    } on AuthException catch (e) {
      if (mounted) showAuthMessage(context, e.message);
    } finally {
      if (mounted) setState(() => _googleLoading = false);
    }
  }

  @override
  void dispose() {
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
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight - 122,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const AuthLogoHeader(
                    title: 'Masuk',
                    subtitle: 'Masuk untuk mengelola stok bahan\nbaku usaha Anda.',
                  ),
                  const SizedBox(height: 24),
                  AuthTextField(
                    label: 'Email',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) =>
                        value == null || !value.contains('@')
                            ? 'Masukkan email yang valid'
                            : null,
                  ),
                  const SizedBox(height: 12),
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
                    validator: (value) =>
                        value == null || value.isEmpty
                            ? 'Password wajib diisi'
                            : null,
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ForgotPasswordScreen(),
                        ),
                      ),
                      child: Text(
                        'Lupa Password?',
                        style: GoogleFonts.plusJakartaSans(
                          color: authBrown,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(11),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFE9C5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.info_outline, color: authOrange, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Akun Purchasing, Kitchen Staff, dan Kasir dibuat oleh Owner. Hubungi Owner jika belum punya akses.',
                            style: GoogleFonts.plusJakartaSans(
                              color: authBrown,
                              fontSize: 10,
                              height: 1.45,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 17),
                  AuthPrimaryButton(
                    text: 'Masuk',
                    onPressed: _login,
                  ),
                  const SizedBox(height: 12),
                  Text('atau', style: GoogleFonts.plusJakartaSans(fontSize: 11)),
                  const SizedBox(height: 12),
                  AuthGoogleButton(
                    onPressed: _loginWithGoogle,
                  ),
                  const SizedBox(height: 13),
                  AuthBottomLink(
                    text: 'Belum memiliki akun? ',
                    action: 'Daftar Sekarang',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RegisterScreen()),
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

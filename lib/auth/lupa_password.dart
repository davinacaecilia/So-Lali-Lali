import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import 'auth_widgets.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  bool _loading = false;

  Future<void> _kirimReset() async {
    if (_loading) return;
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final email = _emailController.text.trim();
      await AuthService.instance.sendPasswordReset(email);
      if (mounted) {
        showAuthMessage(
          context,
          'Tautan reset password sudah dikirim. Cek inbox atau folder spam email $email.',
        );
      }
    } on AuthException catch (e) {
      if (mounted) showAuthMessage(context, e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AuthPageBackground(
      child: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(25, 145, 25, 24),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight - 169),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const AuthLogoHeader(
                    title: 'Lupa Password?',
                    subtitle:
                        'Masukkan email yang terdaftar untuk pengaturan ulang password.',
                    logoWidth: 180,
                  ),
                  const SizedBox(height: 30),
                  AuthTextField(
                    label: 'Email',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) => v == null || !v.contains('@')
                        ? 'Masukkan email yang valid'
                        : null,
                  ),
                  const SizedBox(height: 68),
                  AuthPrimaryButton(
                    text: 'Kirim Tautan Reset',
                    onPressed: _kirimReset,
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 45,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: authNavy,
                        side: BorderSide(color: authNavy.withOpacity(0.6)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Kembali ke Halaman Masuk'),
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

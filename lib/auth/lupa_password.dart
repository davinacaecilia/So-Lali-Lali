import 'package:flutter/material.dart';

import 'auth_widgets.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

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
                        'Masukkan email yang terdaftar untuk simulasi pengaturan ulang password.',
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
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        showAuthMessage(
                          context,
                          'Simulasi berhasil: tautan reset akan dikirim ke ${_emailController.text.trim()}.',
                        );
                      }
                    },
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

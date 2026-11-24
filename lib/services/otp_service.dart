import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'auth_service.dart';

class OtpService {
  OtpService._();
  static final OtpService instance = OtpService._();

  // Isi dengan data dari dashboard EmailJS
  static const _serviceId = 'service_jhdjjnd';
  static const _templateId = 'template_rm41vjk';
  static const _publicKey = 'rEZZw5RW2T74NoNKg';

  String? _code;
  String? _email;
  DateTime? _expiresAt;
  DateTime? _lastSent;
  int _attempts = 0;

  /// Buat kode baru dan kirim ke email.
  Future<void> send(String email) async {
    final now = DateTime.now();
    if (_lastSent != null &&
        email == _email &&
        now.difference(_lastSent!).inSeconds < 30) {
      throw AuthException('Tunggu sebentar sebelum meminta kode baru.');
    }

    final code = (1000 + Random.secure().nextInt(9000)).toString();

    final expiry = now.add(const Duration(minutes: 5));
    final timeText =
        '${expiry.hour.toString().padLeft(2, '0')}:${expiry.minute.toString().padLeft(2, '0')}';

    try {
      final res = await http
          .post(
        Uri.parse('https://api.emailjs.com/api/v1.0/email/send'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'service_id': _serviceId,
          'template_id': _templateId,
          'user_id': _publicKey,
          'template_params': {'to_email': email, 'otp': code, 'time': timeText},
        }),
      )
          .timeout(const Duration(seconds: 20));

      if (res.statusCode != 200) {
        debugPrint('EmailJS error ${res.statusCode}: ${res.body}');
        throw AuthException('Gagal mengirim kode OTP. Coba lagi.');
      }
    } on AuthException {
      rethrow;
    } catch (_) {
      throw AuthException('Gagal mengirim kode OTP. Periksa koneksi internet.');
    }

    // Simpan hanya kalau pengiriman berhasil
    _code = code;
    _email = email;
    _expiresAt = expiry;
    _lastSent = now;
    _attempts = 0;
  }

  /// Mengembalikan null kalau kode benar, atau pesan error kalau salah.
  String? verify(String email, String input) {
    if (_code == null || email != _email) {
      return 'Kode belum dikirim. Minta kode baru.';
    }
    if (DateTime.now().isAfter(_expiresAt!)) {
      return 'Kode sudah kedaluwarsa. Minta kode baru.';
    }
    if (_attempts >= 5) {
      return 'Terlalu banyak percobaan. Minta kode baru.';
    }
    _attempts++;
    if (input.trim() != _code) return 'Kode salah.';

    _code = null; // sekali pakai
    return null;
  }
}
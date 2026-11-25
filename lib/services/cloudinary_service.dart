import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'ingredient_service.dart' show ServiceException;

class CloudinaryService {
  CloudinaryService._();
  static final CloudinaryService instance = CloudinaryService._();

  // Isi dengan data dari dashboard Cloudinary
  static const _cloudName = 'iaxpotjr';
  static const _uploadPreset = 'solalilali';

  /// Mengunggah foto dan mengembalikan link https permanennya.
  Future<String> uploadImage(File file) async {
    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/$_cloudName/image/upload',
    );

    try {
      final request = http.MultipartRequest('POST', uri)
        ..fields['upload_preset'] = _uploadPreset
        ..files.add(await http.MultipartFile.fromPath('file', file.path));

      final streamed =
      await request.send().timeout(const Duration(seconds: 60));
      final res = await http.Response.fromStream(streamed);

      if (res.statusCode != 200) {
        debugPrint('Cloudinary error ${res.statusCode}: ${res.body}');
        throw ServiceException('Gagal mengunggah foto (kode ${res.statusCode}).');
      }

      final url =
      (jsonDecode(res.body) as Map<String, dynamic>)['secure_url'] as String?;
      if (url == null) {
        throw ServiceException('Respons unggah foto tidak valid.');
      }
      return url;
    } on ServiceException {
      rethrow;
    } catch (e) {
      debugPrint('Cloudinary upload error: $e');
      throw ServiceException('Gagal mengunggah foto. Periksa koneksi internet.');
    }
  }
}
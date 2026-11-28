import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Error yang pesannya sudah siap ditampilkan ke user.
class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  @override
  String toString() => message;
}

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  bool _googleReady = false;

  /// Nama route tujuan untuk tiap role.
  /// Role selain owner sementara diarahkan ke '/home' (placeholder).
  static String routeForRole(String role) {
    switch (role) {
      case 'owner':
        return '/owner';
      case 'kasir':
        return '/kasir';
      case 'kitchen':
        return '/kitchen';
      default:
        return '/home';
    }
  }

  Future<void> _initGoogle() async {
    if (_googleReady) return;
    await GoogleSignIn.instance.initialize();
    _googleReady = true;
  }

  /// Masuk / daftar dengan Google. Mengembalikan role user,
  /// atau null kalau user membatalkan pemilihan akun.
  Future<String?> signInWithGoogle() async {
    try {
      await _initGoogle();

      final googleUser = await GoogleSignIn.instance.authenticate();
      final idToken = googleUser.authentication.idToken;
      if (idToken == null) {
        throw AuthException('Gagal mengambil token Google. Coba lagi.');
      }

      final credential = GoogleAuthProvider.credential(idToken: idToken);
      final cred = await _auth.signInWithCredential(credential);
      final user = cred.user!;

      final ref = _db.collection('users').doc(user.uid);
      final doc = await ref.get();

      // Akun baru -> jadikan Owner
      if (!doc.exists) {
        await ref.set({
          'name': user.displayName ?? '',
          'email': user.email ?? '',
          'role': 'owner',
          'isActive': true,
          'createdAt': FieldValue.serverTimestamp(),
        });
        return 'owner';
      }

      // Akun sudah ada: Google hanya boleh untuk Owner
      final data = doc.data()!;
      if (data['role'] != 'owner') {
        await logout();
        throw AuthException('Login Google hanya untuk Owner.');
      }
      if (data['isActive'] != true) {
        await logout();
        throw AuthException('Akun Anda nonaktif. Hubungi Owner.');
      }
      return 'owner';
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) return null;
      throw AuthException('Login Google gagal: ${e.description ?? e.code.name}');
    } on FirebaseAuthException catch (e) {
      throw AuthException(_firebaseMessage(e));
    } on FirebaseException catch (e) {
      throw AuthException('Gagal mengakses database: ${e.message ?? e.code}');
    }
  }

  /// Login email + password. Mengembalikan role user.
  Future<String> login(String email, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return await _checkRole(cred.user!.uid);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_firebaseMessage(e));
    } on FirebaseException catch (e) {
      throw AuthException('Gagal mengakses database: ${e.message ?? e.code}');
    }
  }

  /// Daftar Owner dengan email + password.
  Future<void> registerOwner({
    required String name,
    required String businessName,
    required String email,
    required String password,
  }) async {
    UserCredential? cred;
    try {
      cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _db.collection('users').doc(cred.user!.uid).set({
        'name': name,
        'businessName': businessName,
        'email': email,
        'role': 'owner',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseAuthException catch (e) {
      throw AuthException(_firebaseMessage(e));
    } on FirebaseException catch (e) {
      // Data gagal tersimpan -> hapus akun Auth supaya tidak menggantung
      await cred?.user?.delete();
      throw AuthException('Gagal menyimpan data: ${e.message ?? e.code}');
    }
  }

  /// Cek dokumen user di Firestore, kembalikan role-nya.
  Future<String> _checkRole(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) {
      await logout();
      throw AuthException('Akun belum terdaftar di sistem.');
    }
    final data = doc.data()!;
    if (data['isActive'] != true) {
      await logout();
      throw AuthException('Akun Anda nonaktif. Hubungi Owner.');
    }
    return data['role'] as String;
  }

  /// Kirim email berisi tautan reset password.
  Future<void> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      // Email yang tidak terdaftar sengaja diabaikan supaya orang lain
      // tidak bisa menebak email siapa saja yang punya akun.
      if (e.code == 'user-not-found') return;
      throw AuthException(_firebaseMessage(e));
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    if (_googleReady) await GoogleSignIn.instance.signOut();
  }

  String _firebaseMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-credential':
      case 'wrong-password':
      case 'user-not-found':
        return 'Email atau password salah.';
      case 'invalid-email':
        return 'Format email tidak valid.';
      case 'email-already-in-use':
        return 'Email sudah terdaftar. Silakan masuk.';
      case 'weak-password':
        return 'Password terlalu lemah.';
      case 'too-many-requests':
        return 'Terlalu banyak percobaan. Coba lagi nanti.';
      case 'account-exists-with-different-credential':
        return 'Email ini sudah terdaftar dengan metode login lain.';
      case 'network-request-failed':
        return 'Tidak ada koneksi internet.';
      case 'user-disabled':
        return 'Akun ini dinonaktifkan.';
      default:
        return 'Autentikasi gagal (${e.code}).';
    }
  }
}
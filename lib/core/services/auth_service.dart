// lib/core/services/auth_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  AuthService._internal();

  static final AuthService _instance = AuthService._internal();

  factory AuthService() => _instance;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// REGISTER USER BIASA
  Future<String> register(
    String name,
    String email,
    String password,
  ) async {
    try {
      if (name.isEmpty || email.isEmpty || password.isEmpty) {
        return "Nama, email, dan password wajib diisi.";
      }

      // Buat akun auth
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = cred.user;
      if (user == null) {
        return "Terjadi kesalahan. User tidak ditemukan.";
      }

      // Simpan data user di Firestore
      await _firestore.collection("users").doc(user.uid).set({
        "uid": user.uid,
        "name": name,
        "email": email,
        "role": "user",
        "createdAt": FieldValue.serverTimestamp(),
      });

      // Kirim email verifikasi (kalau belum)
      if (!user.emailVerified) {
        await user.sendEmailVerification();
      }

      // PENTING: Jangan signOut di sini.
      // Biarkan user tetap login supaya halaman verify-pending
      // bisa memanggil resendVerification().
      return "success";
    } on FirebaseAuthException catch (e) {
      return _handleFirebaseAuthException(e);
    } catch (e) {
      debugPrint("register error: $e");
      return "Terjadi kesalahan. Silakan coba lagi.";
    }
  }

  /// LOGIN (ADMIN / USER)
  Future<String> login(
    String identifier, // bisa email user / kode admin
    String password,
  ) async {
    try {
      if (identifier.isEmpty || password.isEmpty) {
        return "Email/Kode dan password wajib diisi.";
      }

      // 1. Cek dulu apakah ini admin (berdasarkan kode)
      final adminSnap = await _firestore
          .collection("pmi_admins")
          .where("code", isEqualTo: identifier)
          .limit(1)
          .get();

      if (adminSnap.docs.isNotEmpty) {
        final admin = adminSnap.docs.first.data();

        final storedPassword = admin["password"]?.toString() ?? "";
        if (password != storedPassword) {
          return "Kode admin atau password salah.";
        }

        final code = admin["code"]?.toString() ?? "";
        final regionName = admin["regionName"]?.toString() ?? "";

        return "admin_success|$code|$regionName";
      }

      // 2. Kalau bukan admin → anggap email user biasa
      final cred = await _auth.signInWithEmailAndPassword(
        email: identifier,
        password: password,
      );

      var user = cred.user;
      if (user == null) {
        return "Akun tidak ditemukan.";
      }

      // Reload untuk memastikan status emailVerified terbaru
      await user.reload();
      user = _auth.currentUser;

      if (user == null) {
        return "Terjadi kesalahan. Silakan login kembali.";
      }

      if (!user.emailVerified) {
        // JANGAN signOut di sini. Biarkan user tetap login
        // supaya halaman verify-pending bisa kirim ulang email verifikasi.
        try {
          await user.sendEmailVerification();
        } catch (e) {
          debugPrint("sendEmailVerification on login error: $e");
        }
        return "unverified";
      }

      return "user_success";
    } on FirebaseAuthException catch (e) {
      return _handleFirebaseAuthException(e);
    } catch (e) {
      debugPrint("login error: $e");
      return "Terjadi kesalahan. Silakan coba lagi.";
    }
  }

  /// KIRIM ULANG EMAIL VERIFIKASI
  Future<String> resendVerification() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return "User tidak ditemukan. Silakan login kembali.";
      }

      await user.reload();
      final refreshedUser = _auth.currentUser;
      if (refreshedUser == null) {
        return "User tidak ditemukan. Silakan login kembali.";
      }

      if (refreshedUser.emailVerified) {
        return "verified";
      }

      await refreshedUser.sendEmailVerification();
      return "sent";
    } on FirebaseAuthException catch (e) {
      return _handleFirebaseAuthException(e);
    } catch (e) {
      debugPrint("resendVerification error: $e");
      return "Terjadi kesalahan saat mengirim ulang email verifikasi.";
    }
  }

  /// Cek lagi status emailVerified
  Future<bool> checkEmailVerified() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      await user.reload();
      return _auth.currentUser?.emailVerified ?? false;
    } catch (e) {
      debugPrint("checkEmailVerified error: $e");
      return false;
    }
  }

  /// LOGOUT
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Mapping error FirebaseAuth → pesan bahasa Indonesia
  String _handleFirebaseAuthException(FirebaseAuthException e) {
    debugPrint("FirebaseAuthException [${e.code}]: ${e.message}");

    switch (e.code) {
      case 'invalid-email':
        return "Format email tidak valid.";
      case 'user-disabled':
        return "Akun ini telah dinonaktifkan.";
      case 'user-not-found':
        return "Akun dengan email tersebut tidak ditemukan.";
      case 'wrong-password':
        return "Password yang dimasukkan salah.";
      case 'email-already-in-use':
        return "Email sudah terdaftar. Silakan gunakan email lain.";
      case 'weak-password':
        return "Password terlalu lemah. Gunakan kombinasi huruf & angka.";
      case 'operation-not-allowed':
        return "Metode login ini sedang tidak diizinkan.";
      default:
        return "Terjadi kesalahan (${e.code}). Silakan coba lagi.";
    }
  }
}

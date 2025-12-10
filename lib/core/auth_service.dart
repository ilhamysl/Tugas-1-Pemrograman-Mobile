// lib/core/services/auth_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  AuthService._internal();

  static final AuthService _instance = AuthService._internal();

  factory AuthService() => _instance;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// ======================================================
  ///   SIMPAN FCM TOKEN USER KE FIRESTORE
  /// ======================================================
  Future<void> _saveFcmToken(String uid) async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        await _firestore.collection("users").doc(uid).update({
          "fcmToken": token,
        });
      }
    } catch (e) {
      debugPrint("Error save FCM token: $e");
    }
  }

  /// ============================
  /// REGISTER USER BIASA
  /// ============================
  Future<String> register(
    String name,
    String email,
    String password,
  ) async {
    try {
      if (name.isEmpty || email.isEmpty || password.isEmpty) {
        return "Nama, email, dan password wajib diisi.";
      }

      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = cred.user;
      if (user == null) {
        return "Terjadi kesalahan. User tidak ditemukan.";
      }

      await _firestore.collection("users").doc(user.uid).set({
        "uid": user.uid,
        "name": name,
        "email": email,
        "role": "user",
        "fcmToken": null,
        "createdAt": FieldValue.serverTimestamp(),
      });

      // SIMPAN TOKEN FCM SETELAH REGISTER
      await _saveFcmToken(user.uid);

      if (!user.emailVerified) {
        await user.sendEmailVerification();
      }

      return "success";
    } on FirebaseAuthException catch (e) {
      return _handleFirebaseAuthException(e);
    } catch (e) {
      debugPrint("register error: $e");
      return "Terjadi kesalahan. Silakan coba lagi.";
    }
  }

  /// ============================
  /// LOGIN (ADMIN / USER)
  /// ============================
  Future<String> login(
    String identifier,
    String password,
  ) async {
    try {
      if (identifier.isEmpty || password.isEmpty) {
        return "Email/Kode dan password wajib diisi.";
      }

      // CEK ADMIN
      final adminEmailSnap = await _firestore
          .collection("pmi_admins")
          .where("email", isEqualTo: identifier)
          .limit(1)
          .get();

      if (adminEmailSnap.docs.isNotEmpty) {
        // LOGIN ADMIN VIA FIREBASEAUTH
        final cred = await _auth.signInWithEmailAndPassword(
          email: identifier,
          password: password,
        );

        final data = adminEmailSnap.docs.first.data();
        final code = data["code"] ?? "";
        final regionName = data["regionName"] ?? "";

        return "admin_success|$code|$regionName";
      }

      // LOGIN USER
      final cred = await _auth.signInWithEmailAndPassword(
        email: identifier,
        password: password,
      );

      var user = cred.user;
      if (user == null) {
        return "Akun tidak ditemukan.";
      }

      await user.reload();
      user = _auth.currentUser;

      if (user == null) {
        return "Terjadi kesalahan. Silakan login kembali.";
      }

      if (!user.emailVerified) {
        try {
          await user.sendEmailVerification();
        } catch (e) {
          debugPrint("sendEmailVerification on login error: $e");
        }
        return "unverified";
      }

      // SIMPAN TOKEN FCM SETELAH LOGIN USER
      await _saveFcmToken(user.uid);

      return "user_success";
    } on FirebaseAuthException catch (e) {
      return _handleFirebaseAuthException(e);
    } catch (e) {
      debugPrint("login error: $e");
      return "Terjadi kesalahan. Silakan coba lagi.";
    }
  }

  /// ============================
  /// RESEND VERIFICATION EMAIL
  /// ============================
  Future<String> resendVerification() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return "User tidak ditemukan.";

      await user.reload();
      final refreshedUser = _auth.currentUser;
      if (refreshedUser == null) return "User tidak ditemukan.";

      if (refreshedUser.emailVerified) return "verified";

      await refreshedUser.sendEmailVerification();
      return "sent";
    } on FirebaseAuthException catch (e) {
      return _handleFirebaseAuthException(e);
    } catch (e) {
      debugPrint("resendVerification error: $e");
      return "Terjadi kesalahan saat mengirim ulang email verifikasi.";
    }
  }

  /// ============================
  /// CHECK EMAIL VERIFIED
  /// ============================
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

  /// ============================
  /// LOGOUT
  /// ============================
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// ============================
  /// ERROR HANDLING
  /// ============================
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
        return "Email sudah terdaftar.";
      case 'weak-password':
        return "Password terlalu lemah.";
      default:
        return "Terjadi kesalahan (${e.code}). Silakan coba lagi.";
    }
  }
}

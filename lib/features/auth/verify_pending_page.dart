// lib/features/auth/verify_pending_page.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:darahcepat/core/auth_service.dart';


class VerifyPendingPage extends StatefulWidget {
  const VerifyPendingPage({super.key});

  @override
  State<VerifyPendingPage> createState() => _VerifyPendingPageState();
}

class _VerifyPendingPageState extends State<VerifyPendingPage> {
  // --- DEFINISI WARNA MERAH KONSISTEN SEBAGAI AKSEN ---
  static const Color appPrimaryRed = Color(0xFFE53935);
  static const Color appLightRed = Color(0xFFFFEEEE);

  bool _isSending = false;

  String get _currentEmail {
    final user = FirebaseAuth.instance.currentUser;
    return user?.email ?? "-";
  }

  Future<void> _handleResend() async {
    setState(() {
      _isSending = true;
    });

    final res = await AuthService().resendVerification();

    setState(() {
      _isSending = false;
    });

    if (!mounted) return;

    String message;
    if (res == "sent") {
      message = "Email verifikasi sudah dikirim ulang ke $_currentEmail.";
    } else if (res == "verified") {
      message = "Email sudah terverifikasi. Silakan login kembali.";
    } else {
      message = res;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _backToLogin() async {
    await AuthService().signOut();
    if (!mounted) return;

    Navigator.pushNamedAndRemoveUntil(
      context,
      "/login",
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        // Perbaikan: SingleChildScrollView untuk menghindari RenderFlex Overflow
        child: SingleChildScrollView( 
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 48), 
                // Ikon Merah KONSISTEN
                const Icon(
                  Icons.mark_email_read_outlined,
                  size: 80,
                  color: appPrimaryRed,
                ),
                const SizedBox(height: 24),
                const Text(
                  "Verifikasi Email Anda",
                  style: TextStyle(
                    fontSize: 24, 
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Kami telah mengirim email verifikasi ke:",
                ),
                const SizedBox(height: 8),
                // Highlight Email
                Container(
                  padding: const EdgeInsets.all(12),
                  width: double.infinity, 
                  decoration: BoxDecoration(
                    color: appLightRed, 
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: appPrimaryRed.withOpacity(0.5)), 
                  ),
                  child: Text(
                    _currentEmail,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: appPrimaryRed, 
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Silakan cek kotak masuk atau folder spam Anda. Klik tautan verifikasi di email, lalu kembali ke aplikasi dan silakan login.",
                  style: TextStyle(height: 1.5), 
                ),
                const SizedBox(height: 40), 
                // --- Tombol Utama: Kirim Ulang (Merah solid) ---
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSending ? null : _handleResend,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: appPrimaryRed, 
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10), 
                      ),
                    ),
                    child: _isSending
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            "Kirim Ulang Email Verifikasi",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                  ),
                ),
                const SizedBox(height: 12),
                // --- Tombol Sekunder: Kembali ke Login (Outlined Merah) ---
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _backToLogin,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10), 
                      ),
                      side: const BorderSide(color: appPrimaryRed, width: 2), 
                    ),
                    child: const Text(
                      "Kembali ke Halaman Login",
                      style: TextStyle(color: appPrimaryRed, fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ),
                ),
                 const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
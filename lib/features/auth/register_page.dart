// lib/features/auth/register_page.dart

import 'package:flutter/material.dart';
import 'package:darahcepat/core/auth_service.dart';


class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // --- DEFINISI WARNA MERAH KONSISTEN SEBAGAI AKSEN ---
  static const Color appPrimaryRed = Color(0xFFE53935);
  
  final TextEditingController _nameC = TextEditingController();
  final TextEditingController _emailC = TextEditingController();
  final TextEditingController _passC = TextEditingController();

  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameC.dispose();
    _emailC.dispose();
    _passC.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final auth = AuthService();
    final res = await auth.register(
      _nameC.text.trim(),
      _emailC.text.trim(),
      _passC.text.trim(),
    );

    setState(() {
      _isLoading = false;
    });

    if (!mounted) return;

    if (res == "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Pendaftaran berhasil. Cek email untuk verifikasi akun.",
          ),
        ),
      );

      // Arahkan langsung ke halaman verify-pending
      Navigator.pushReplacementNamed(context, "/verify-pending");
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Daftar Akun Baru"),
        backgroundColor: Colors.white, 
        elevation: 0.5, 
        foregroundColor: appPrimaryRed, 
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 24),
                // Input Nama
                TextFormField(
                  controller: _nameC,
                  decoration: const InputDecoration(
                    labelText: "Nama Lengkap",
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))), 
                    prefixIcon: Icon(Icons.badge_outlined, color: appPrimaryRed), 
                    filled: true,
                    fillColor: Color(0xFFF5F5F5),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return "Nama wajib diisi.";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Input Email
                TextFormField(
                  controller: _emailC,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: "Email",
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))), 
                    prefixIcon: Icon(Icons.email_outlined, color: appPrimaryRed), 
                    filled: true,
                    fillColor: Color(0xFFF5F5F5),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return "Email wajib diisi.";
                    }
                    if (!val.contains("@")) {
                      return "Format email tidak valid.";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Input Password
                TextFormField(
                  controller: _passC,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: "Password (Min. 6 Karakter)",
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))), 
                    prefixIcon: Icon(Icons.lock_outline, color: appPrimaryRed), 
                    filled: true,
                    fillColor: Color(0xFFF5F5F5),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return "Password wajib diisi.";
                    }
                    if (val.trim().length < 6) {
                      return "Minimal 6 karakter.";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 40),
                // Tombol Daftar (Merah solid)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleRegister,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: appPrimaryRed, 
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            "Daftar",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                  ),
                ),
                const SizedBox(height: 40),
                // Navigasi ke Login
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Sudah punya akun?"),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        "Login Sekarang",
                        style: TextStyle(fontWeight: FontWeight.bold, color: appPrimaryRed),
                      ),
                    ),
                  ],
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
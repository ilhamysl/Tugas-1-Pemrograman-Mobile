// lib/features/auth/login_page.dart

import 'package:flutter/material.dart';
import 'package:darahcepat/core/services/auth_service.dart';
import 'package:darahcepat/features/home/admin_home_page.dart';
import 'package:darahcepat/features/home/user_home_page.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // --- DEFINISI WARNA MERAH KONSISTEN SEBAGAI AKSEN ---
  static const Color appPrimaryRed = Color(0xFFE53935);

  final TextEditingController _identifierC = TextEditingController();
  final TextEditingController _passwordC = TextEditingController();

  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _identifierC.dispose();
    _passwordC.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final auth = AuthService();
    final res = await auth.login(
      _identifierC.text.trim(),
      _passwordC.text.trim(),
    );

    setState(() {
      _isLoading = false;
    });

    if (!mounted) return;

    if (res == "user_success") {
      // User biasa
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const UserHomePage()),
        (route) => false,
      );
      return;
    }

    if (res == "unverified") {
      // User sudah terdaftar tapi email belum terverifikasi.
      Navigator.pushNamed(context, "/verify-pending");
      return;
    }

    if (res.startsWith("admin_success|")) {
      // res format: "admin_success|kode|regionName"
      final parts = res.split("|");
      final code = parts.length > 1 ? parts[1] : "-";
      final regionName = parts.length > 2 ? parts[2] : "-";

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => AdminHomePage(
            adminCode: code,
            regionName: regionName,
          ),
        ),
        (route) => false,
      );
      return;
    }

    // Jika bukan salah satu di atas → dianggap pesan error
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(res)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 80),
                // Branding Text: Darah Cepat
                Text(
                  "Darah Cepat",
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.w900, 
                        color: appPrimaryRed, 
                        fontSize: 34,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Masuk ke Akun Anda",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 48),
                // Input Email/Kode Admin
                TextFormField(
                  controller: _identifierC,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: "Email / Kode Admin", 
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))), 
                    prefixIcon: Icon(Icons.person_outline, color: appPrimaryRed), 
                    filled: true,
                    fillColor: Color(0xFFF5F5F5), 
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return "Field ini wajib diisi.";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Input Password
                TextFormField(
                  controller: _passwordC,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: "Password",
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))), 
                    prefixIcon: Icon(Icons.lock_outline, color: appPrimaryRed), 
                    filled: true,
                    fillColor: Color(0xFFF5F5F5),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return "Password wajib diisi.";
                    }
                    return null;
                  },
                ),
                // Lupa Password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () { /* Tambahkan navigasi Lupa Password */ },
                    child: const Text(
                      "Lupa Password?",
                      style: TextStyle(color: appPrimaryRed, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                // Tombol Login (Merah solid)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
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
                            "Login",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                  ),
                ),
                const SizedBox(height: 40),
                // Navigasi ke Register
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Belum punya akun?"),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, "/register");
                      },
                      child: const Text(
                        "Daftar Sekarang",
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
// lib/features/auth/login_page.dart

import 'package:flutter/material.dart';
import 'package:darahcepat/core/auth_service.dart';
import 'package:darahcepat/features/admin/admin_main_page.dart';
import 'package:darahcepat/features/user/user_main_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
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

    setState(() => _isLoading = true);

    final auth = AuthService();
    final res = await auth.login(
      _identifierC.text.trim(),
      _passwordC.text.trim(),
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    // USER BIASA
    if (res == "user_success") {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const UserMainPage()),
        (route) => false,
      );
      return;
    }

    // EMAIL BELUM VERIFIKASI
    if (res == "unverified") {
      Navigator.pushNamed(context, "/verify-pending");
      return;
    }

    // ADMIN
    if (res.startsWith("admin_success|")) {
      final parts = res.split("|");
      final data = {
        "code": parts[1],
        "regionName": parts[2],
      };

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => AdminMainPage(adminData: data),
        ),
        (route) => false,
      );
      return;
    }

    // ERROR
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
              children: [
                const SizedBox(height: 80),
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

                // TextField Email/Kode Admin
                TextFormField(
                  controller: _identifierC,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: "Email / Kode Admin",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    prefixIcon: Icon(Icons.person_outline,
                        color: appPrimaryRed),
                    filled: true,
                    fillColor: Color(0xFFF5F5F5),
                  ),
                  validator: (val) =>
                      (val == null || val.trim().isEmpty)
                          ? "Field ini wajib diisi."
                          : null,
                ),

                const SizedBox(height: 16),

                // TextField Password
                TextFormField(
                  controller: _passwordC,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: "Password",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    prefixIcon: Icon(Icons.lock_outline, color: appPrimaryRed),
                    filled: true,
                    fillColor: Color(0xFFF5F5F5),
                  ),
                  validator: (val) =>
                      (val == null || val.trim().isEmpty)
                          ? "Password wajib diisi."
                          : null,
                ),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: const Text(
                      "Lupa Password?",
                      style: TextStyle(
                          color: appPrimaryRed,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // TOMBOL LOGIN
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: appPrimaryRed,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
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
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                  ),
                ),

                const SizedBox(height: 40),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Belum punya akun?"),
                    TextButton(
                      onPressed: () =>
                          Navigator.pushNamed(context, "/register"),
                      child: const Text(
                        "Daftar Sekarang",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: appPrimaryRed),
                      ),
                    )
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

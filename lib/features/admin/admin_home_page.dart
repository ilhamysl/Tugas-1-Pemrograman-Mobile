import 'package:flutter/material.dart';

class AdminHomePage extends StatelessWidget {
  final String adminCode;
  final String regionName;

  const AdminHomePage({
    super.key,
    required this.adminCode,
    required this.regionName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard Admin PMI"),
        backgroundColor: const Color(0xFFD50000),
      ),
      body: Center(
        child: Text(
          "Halo Admin\n$regionName\n(Kode: $adminCode)",
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFFD50000),
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

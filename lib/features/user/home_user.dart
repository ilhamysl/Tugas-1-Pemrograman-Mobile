import 'package:flutter/material.dart';

class UserHomePage extends StatelessWidget {
  const UserHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Home User")),
      body: const Center(
        child: Text("Berhasil Login!"),
      ),
    );
  }
}

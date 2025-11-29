import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'features/auth/login_page.dart';
import 'features/auth/register_page.dart';
import 'features/auth/verify_pending_page.dart';
import 'features/home/user_home_page.dart';
import 'features/home/admin_home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const DarahCepatApp());
}

class DarahCepatApp extends StatelessWidget {
  const DarahCepatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DarahCepat',
      debugShowCheckedModeBanner: false,
      initialRoute: "/login",
      routes: {
        "/login": (_) => const LoginPage(),
        "/register": (_) => const RegisterPage(),
        "/verify-pending": (_) => const VerifyPendingPage(),
      },
    );
  }
}

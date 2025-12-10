import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'core/notification_service.dart';
import 'firebase_options.dart';

// AUTH
import 'features/auth/login_page.dart';
import 'features/auth/register_page.dart';
import 'features/auth/verify_pending_page.dart';

// USER PAGES
import 'features/user/user_main_page.dart';
import 'features/user/user_pick_pmi_page.dart';
import 'features/user/user_blood_stock_page.dart';
import 'features/user/user_event_page.dart';
import 'features/user/user_notification_page.dart';

// ADMIN PAGE
import 'features/admin/admin_main_page.dart';

/// Background handler FCM (WAJIB global)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await NotificationService.initialize();

  
  FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .update({"fcmToken": newToken});
    }
  });

  
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  
  FirebaseMessaging.instance.getInitialMessage().then((message) {
    if (message != null) {
      debugPrint("APP DIBUKA DARI NOTIFIKASI (terminated)");
      // → bisa arahkan user ke halaman tertentu kalau mau
    }
  });

 
  FirebaseMessaging.onMessageOpenedApp.listen((message) {
    debugPrint("USER MENEKAN NOTIFIKASI → ${message.data}");
  });

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

        "/user-main": (_) => const UserMainPage(),
        "/pick-pmi": (_) => const UserPickPmiPage(),
        "/user-blood-stock": (_) => const UserBloodStockPage(),
        "/event-detail": (_) => const UserEventPage(),
        "/user-notif": (_) => const UserNotificationPage(),

        "/admin-main": (_) => const AdminMainPage(),
      },
    );
  }
}

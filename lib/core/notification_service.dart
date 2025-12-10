import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();

  /// INITIALIZATION
  static Future<void> initialize() async {
    // Request permission
    await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Local notif settings
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    const initSettings = InitializationSettings(
      android: androidSettings,
    );

    await _local.initialize(initSettings);

    // Foreground handler → popup
    FirebaseMessaging.onMessage.listen((message) async {
      _showLocal(message);
      _saveToFirestore(message);
    });
  }

  /// Show popup notification inside the app (foreground)
  static Future<void> _showLocal(RemoteMessage message) async {
    const androidDetails = AndroidNotificationDetails(
      'default_channel',
      'General Notifications',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
    );

    const details = NotificationDetails(android: androidDetails);

    await _local.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      message.notification?.title ?? "Notifikasi",
      message.notification?.body ?? "",
      details,
    );
  }

  /// Save notification to Firestore → Page bisa menampilkan
  static Future<void> _saveToFirestore(RemoteMessage message) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .collection("notifications")
        .add({
      "title": message.notification?.title ?? "",
      "body": message.notification?.body ?? "",
      "type": message.data["type"] ?? "",
      "timestamp": DateTime.now(),
    });
  }
}

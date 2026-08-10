import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class AppNotification {
  final String id;
  final String title;
  final String body;
  final DateTime createdAt;

  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
  });

  factory AppNotification.fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data();
    final ts = d['createdAt'];
    return AppNotification(
      id: doc.id,
      title: d['title'] ?? '',
      body: d['body'] ?? '',
      createdAt: ts is Timestamp ? ts.toDate() : DateTime.now(),
    );
  }
}

/// Free-tier notification system: the Admin Panel writes a document to the
/// `notifications` collection, and this service listens to that collection
/// in real time. While the app is open, new notifications appear instantly
/// as a real Android system notification (not just an in-app banner) - no
/// server/Cloud Functions needed, Firestore's own realtime listeners do the
/// work. This does NOT reach a fully closed app in the background; that
/// needs an actual FCM push send from a server, which requires Firebase's
/// paid Blaze plan (Cloud Functions). This free version covers "real time
/// while using the app" plus a notification history screen.
class NotificationService {
  static final _db = FirebaseFirestore.instance;
  static final _localNotifications = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);
    await _localNotifications.initialize(initSettings);

    const channel = AndroidNotificationChannel(
      'laws_and_legals_updates',
      'Updates',
      description: 'New posts and announcements from Laws And Legals',
      importance: Importance.high,
    );
    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    _initialized = true;
  }

  static Future<void> showLocalNotification(AppNotification n) async {
    await init();
    await _localNotifications.show(
      n.id.hashCode,
      n.title,
      n.body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'laws_and_legals_updates',
          'Updates',
          channelDescription: 'New posts and announcements from Laws And Legals',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
    );
  }

  static Stream<List<AppNotification>> watchNotifications() {
    return _db
        .collection('notifications')
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snap) => snap.docs.map(AppNotification.fromDoc).toList());
  }

  static Future<void> deleteNotification(String id) async {
    try {
      await _db.collection('notifications').doc(id).delete();
    } catch (_) {
      // Ignore - the person can retry the swipe if it fails offline.
    }
  }

  static Future<void> requestPermission() async {
    try {
      await FirebaseMessaging.instance.requestPermission();
      await _localNotifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    } catch (_) {
      // Messaging not fully configured yet - safe to ignore, in-app
      // real-time notifications still work via Firestore regardless.
    }
  }
}

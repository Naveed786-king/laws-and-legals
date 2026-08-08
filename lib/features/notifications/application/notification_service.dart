import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

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
/// (no server/Cloud Functions needed - Firestore's own realtime listeners
/// do the work). This does NOT reach a fully closed app in the background;
/// that needs an actual FCM push send from a server, which requires
/// Firebase's paid Blaze plan (Cloud Functions). This free version covers
/// "real time while using the app" plus a notification history screen.
class NotificationService {
  static final _db = FirebaseFirestore.instance;

  static Stream<List<AppNotification>> watchNotifications() {
    return _db
        .collection('notifications')
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snap) => snap.docs.map(AppNotification.fromDoc).toList());
  }

  static Future<void> requestPermission() async {
    try {
      await FirebaseMessaging.instance.requestPermission();
    } catch (_) {
      // Messaging not fully configured yet - safe to ignore, in-app
      // real-time notifications still work via Firestore regardless.
    }
  }
}

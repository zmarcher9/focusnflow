import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> init(String userId) async {
    // Request permission
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Save FCM token to user's Firestore doc
    final token = await _messaging.getToken();
    if (token != null) {
      await _db.collection('users').doc(userId).update({'fcmToken': token});
    }

    // Handle token refresh
    _messaging.onTokenRefresh.listen((newToken) {
      _db.collection('users').doc(userId).update({'fcmToken': newToken});
    });

    // Foreground messages
    FirebaseMessaging.onMessage.listen((message) {
      // Show in-app snackbar or notification
      final notification = message.notification;
      if (notification != null) {
        // Handle foreground notification display here
      }
    });
  }

  // Schedule a session reminder — this stores the session in Firestore
  // A Cloud Function would read this and send the FCM at the right time
  Future<void> scheduleSessionReminder({
    required String groupId,
    required String groupName,
    required DateTime sessionTime,
    required List<String> memberIds,
  }) async {
    await _db.collection('sessions').add({
      'groupId': groupId,
      'groupName': groupName,
      'sessionTime': sessionTime.toIso8601String(),
      'memberIds': memberIds,
      'reminderSent': false,
      'createdAt': DateTime.now().toIso8601String(),
    });
  }
}
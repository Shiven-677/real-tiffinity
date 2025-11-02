import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:typed_data'; // Add this import for Int64List

// Top-level function for background messages
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  // Initialize notifications
  Future<void> initialize() async {
    // Request permission for iOS
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    }

    // Initialize local notifications
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/launcher_icon'); // app logo

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
          requestSoundPermission: true,
          requestBadgePermission: true,
          requestAlertPermission: true,
        );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Register background message handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle notification taps when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);
  }

  // Save FCM token to Firestore for the logged-in mess owner
  Future<void> saveTokenToFirestore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    String? token = await _firebaseMessaging.getToken();
    if (token == null) return;

    // Find the mess document for this owner
    final messQuery =
        await FirebaseFirestore.instance
            .collection('messes')
            .where('ownerId', isEqualTo: user.uid)
            .limit(1)
            .get();

    if (messQuery.docs.isNotEmpty) {
      await messQuery.docs.first.reference.update({
        'fcmToken': token,
        'tokenUpdatedAt': FieldValue.serverTimestamp(),
      });
      print('FCM Token saved: $token');
    }

    // Listen for token refresh
    _firebaseMessaging.onTokenRefresh.listen((newToken) async {
      if (messQuery.docs.isNotEmpty) {
        await messQuery.docs.first.reference.update({
          'fcmToken': newToken,
          'tokenUpdatedAt': FieldValue.serverTimestamp(),
        });
      }
    });
  }

  // Handle foreground messages with loud notification
  void _handleForegroundMessage(RemoteMessage message) {
    print('Foreground message: ${message.notification?.title}');

    _showLoudNotification(
      title: message.notification?.title ?? 'New Order',
      body: message.notification?.body ?? 'You have a new order',
      payload: message.data.toString(),
    );
  }

  // Show loud notification with custom sound
  Future<void> _showLoudNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    // Create vibration pattern as Int64List
    final Int64List vibrationPattern = Int64List.fromList([0, 1000, 500, 1000]);

    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'order_channel', // Channel ID
          'Order Notifications', // Channel name
          channelDescription: 'Notifications for new orders',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
          vibrationPattern: vibrationPattern,
          // Remove custom sound if you don't have the file
          // sound: RawResourceAndroidNotificationSound('notification_sound'),
        );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      // Remove custom sound if you don't have the file
      // sound: 'notification_sound.aiff',
    );

    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecond, // Unique ID
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  // Handle notification tap
  void _onNotificationTap(NotificationResponse response) {
    print('Notification tapped: ${response.payload}');
    // Navigate to orders page or specific order
  }

  void _handleNotificationTap(RemoteMessage message) {
    print('Notification opened app: ${message.data}');
    // Navigate based on message data
  }

  // Send notification when order is placed (called from customer app)
  Future<void> sendOrderNotificationToMess({
    required String messId,
    required String orderId,
    required String customerName,
    required double totalAmount,
  }) async {
    try {
      final messDoc =
          await FirebaseFirestore.instance
              .collection('messes')
              .doc(messId)
              .get();

      final messData = messDoc.data();
      final fcmToken = messData?['fcmToken'] as String?;

      if (fcmToken == null) {
        print('No FCM token found for this mess');
        return;
      }

      // Create notification document in Firestore
      await FirebaseFirestore.instance.collection('notifications').add({
        'messId': messId,
        'fcmToken': fcmToken,
        'title': '🔔 New Order Received!',
        'body':
            'Order #$orderId from $customerName - ₹${totalAmount.toStringAsFixed(0)}',
        'orderId': orderId,
        'type': 'new_order',
        'createdAt': FieldValue.serverTimestamp(),
        'sent': false,
      });

      print('Notification queued for mess owner');
    } catch (e) {
      print('Error sending notification: $e');
    }
  }
}

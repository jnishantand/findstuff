import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';

class FirebaseNotificationManager {
  static final FirebaseNotificationManager _instance = FirebaseNotificationManager._internal();
  factory FirebaseNotificationManager() => _instance;

  FirebaseNotificationManager._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  /// Call this once at app start (e.g. main)
  Future<void> initialize() async {
    await Firebase.initializeApp();

    // Setup local notifications for foreground
    await _initLocalNotifications();

    // Request permission for iOS
    await _requestPermissions();

    // Setup background message handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handle messages when app is in foreground
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Optionally handle messages when app opened from background/terminated
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

    // Get & print token
    String? token = await _messaging.getToken();
    debugPrint('FCM Token: $token');

    // You may want to send this token to your server here or later
  }

  /// Background message handler (must be top-level or static function)
  static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    await Firebase.initializeApp();
    debugPrint('Handling background message: ${message.messageId}');
    // You can handle background message here or show notifications
  }

  Future<void> _initLocalNotifications() async {
    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initSettings =
    InitializationSettings(android: androidSettings);

    await _flutterLocalNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        debugPrint('Notification tapped with payload: ${response.payload}');
        // Add navigation or other logic here if needed
      },
    );

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'default_channel',
      'Default Notifications',
      description: 'This channel is used for important notifications.',
      importance: Importance.high,
    );

    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  Future<void> _requestPermissions() async {
    if (Platform.isIOS) {
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        debugPrint('User granted notification permission');
      } else {
        debugPrint('User declined or has not accepted notification permission');
      }
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('Foreground message received: ${message.messageId}');

    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null && android != null) {
      _flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'default_channel',
            'Default Notifications',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
        ),
        payload: message.data['payload'] ?? '',
      );
    }
  }

  void _handleMessageOpenedApp(RemoteMessage message) {
    debugPrint('Notification caused app to open: ${message.messageId}');
    // Navigate user to specific screen or handle deep link here
  }

  /// Get current device token
  Future<String?> getToken() async => _messaging.getToken();

  /// Subscribe to topic
  Future<void> subscribeToTopic(String topic) async =>
      _messaging.subscribeToTopic(topic);

  /// Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async =>
      _messaging.unsubscribeFromTopic(topic);
}

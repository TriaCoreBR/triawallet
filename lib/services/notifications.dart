import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  final StreamController<RemoteMessage> _messageStreamController = StreamController<RemoteMessage>.broadcast();

  // Stream that can be listened to for notification events
  Stream<RemoteMessage> get onNotificationReceived => _messageStreamController.stream;

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  Future<void> initialize() async {
    await Firebase.initializeApp();
    await _requestPermissions();
    await _initializeLocalNotifications();
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    _messaging.onTokenRefresh.listen(_handleTokenRefresh);
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      _handleInitialMessage(initialMessage);
    }
    await getToken();
  }

  Future<void> _requestPermissions() async {
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    debugPrint('User granted permission: [32m[1m[4m${settings.authorizationStatus}[0m');
  }

  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/launcher_icon');
    final DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        debugPrint('Notification response received: ${response.payload}');
        if (response.payload != null) {
          final Map<String, dynamic> data = json.decode(response.payload!);
          _handleNotificationTap(data);
        }
      },
    );
    await _createNotificationChannel();
  }

  Future<void> _createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'triacore_notifications',
      'Triacore Notifications',
      description: 'Notifications from Triacore app',
      importance: Importance.high,
    );
    final AndroidFlutterLocalNotificationsPlugin? androidPlugin = _localNotifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(channel);
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('Got a message whilst in the foreground!');
    debugPrint('Message data: ${message.data}');
    if (message.notification != null) {
      debugPrint('Message also contained a notification: ${message.notification!.title}');
      _showLocalNotification(message);
    }
    _messageStreamController.add(message);
  }

  void _handleMessageOpenedApp(RemoteMessage message) {
    debugPrint('A new onMessageOpenedApp event was published!');
    debugPrint('Message data: ${message.data}');
    _messageStreamController.add(message);
    _handleNotificationTap(message.data);
  }

  void _handleInitialMessage(RemoteMessage message) {
    debugPrint('App opened from terminated state with message: ${message.data}');
    _messageStreamController.add(message);
    _handleNotificationTap(message.data);
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;
    if (notification != null && android != null) {
      await _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'triacore_notifications',
            'Triacore Notifications',
            channelDescription: 'Notifications from Triacore app',
            icon: android.smallIcon,
          ),
          iOS: const DarwinNotificationDetails(),
        ),
        payload: json.encode(message.data),
      );
    }
  }

  void _handleNotificationTap(Map<String, dynamic> data) {
    if (data.containsKey('transactionId')) {
      debugPrint('Should navigate to transaction: ${data['transactionId']}');
    }
  }

  Future<String?> getToken() async {
    String? token = (kDebugMode) ? "mockFcmToken" : await _messaging.getToken();
    if (token != null) {
      debugPrint('FCM Token: $token');
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('fcm_token', token);
    }
    return token;
  }

  Future<void> subscribeToTopic(String topic) async {
    await _messaging.subscribeToTopic(topic);
    debugPrint('Subscribed to topic: $topic');
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    await _messaging.unsubscribeFromTopic(topic);
    debugPrint('Unsubscribed from topic: $topic');
  }

  void dispose() {
    _messageStreamController.close();
  }

  void _handleTokenRefresh(String token) async {
    debugPrint('FCM Token refreshed: $token');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('fcm_token', token);
    await _updateTokenOnServer(token);
  }

  Future<void> _updateTokenOnServer(String token) async {
    final prefs = await SharedPreferences.getInstance();
    final hashedDescriptor = prefs.getString('hashed_descriptor');
    if (hashedDescriptor != null) {
      try {
        final platform = Platform.isAndroid ? "android" : "ios";
        final response = await http.post(
          Uri.https('basetria.xyz', '/users/fcm'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'user_id': hashedDescriptor,
            'fcm_token': token,
            'platform': platform,
          }),
        );
        if (response.statusCode == 200 || response.statusCode == 201) {
          debugPrint('FCM token successfully updated on server');
        } else {
          debugPrint('Failed to update FCM token on server: ${response.statusCode}');
          if (kDebugMode) {
            debugPrint('Response: ${response.body}');
          }
        }
      } catch (e) {
        debugPrint('Error updating FCM token on server: $e');
      }
    } else {
      debugPrint('Could not update FCM token: user ID not found');
    }
  }
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint("Handling a background message: \u001b[32m\u001b[1m\u001b[4m[0m");
}
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
    
    // Update these lines to use the correct method names
    FirebaseMessaging.onMessage.listen((message) => _handleMessage(message));
    FirebaseMessaging.onMessageOpenedApp.listen((message) => _onMessageOpenedApp(message));
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    
    // Update token refresh handler
    _messaging.onTokenRefresh.listen((token) => _onTokenRefresh());
    
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
      onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
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

  void _handleMessage(RemoteMessage message) async {
    if (message.notification != null) {
      _showLocalNotification(message);
    }
    _messageStreamController.add(message);
  }

  void _onMessageOpenedApp(RemoteMessage message) {
    _handleNotificationTap(message.data);
  }

  void _handleInitialMessage(RemoteMessage message) {
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
    if (data['type'] == 'transaction') {
      final transactionId = data['transactionId'];
      if (transactionId != null) {
        // Navigate to transaction details
      }
    }
  }

  Future<String?> getToken() async {
    String? token = (kDebugMode) ? "mockFcmToken" : await _messaging.getToken();
    if (token != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('fcm_token', token);
    }
    return token;
  }

  Future<void> subscribeToTopic(String topic) async {
    await FirebaseMessaging.instance.subscribeToTopic(topic);
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    await FirebaseMessaging.instance.unsubscribeFromTopic(topic);
  }

  void dispose() {
    _messageStreamController.close();
  }

  void _onTokenRefresh() async {
    final token = await FirebaseMessaging.instance.getToken();
    await _updateTokenOnServer(token);
  }

  Future<void> _updateTokenOnServer(String? token) async {
    if (token == null) return;

    final userId = await _getUserId();
    if (userId != null) {
      try {
        await http.post(
          Uri.parse('https://api.triacore.com.br/api/users/$userId/fcm-token'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'fcm_token': token}),
        );
      } catch (e) {
        // Silent error
      }
    }
  }

  Future<String?> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('hashed_descriptor');
  }

  Future<void> _onDidReceiveNotificationResponse(NotificationResponse response) async {
    // Handle notification tap
  }
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Handle background message
}
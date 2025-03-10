import 'dart:developer';
import 'dart:io';

import 'package:android_id/android_id.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:gark_academy/services/auth_service.dart';
import 'package:gark_academy/utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PushNotificationService {
  String token = "InvalidToken";
  final firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  AndroidNotificationChannel? channel;
  final dio = Dio();
  final AuthService _authService = AuthService();

  /// Retrieve FCM Token with error handling
  Future<void> getFCMToken() async {
    try {
      log("Attempting to retrieve FCM token");

      // Ensure token is cleared before fetching
      await firebaseMessaging.deleteToken();
      String? newToken;

      if (Platform.isIOS) {
        newToken = await firebaseMessaging.getAPNSToken();
      } else {
        newToken = await firebaseMessaging.getToken();
      }

      if (newToken != null && newToken.isNotEmpty) {
        await saveToken(newToken);
        updateFCMToken(newToken);
        log("FCM Token retrieved successfully: $newToken");
      } else {
        log("FCM Token retrieval failed: Token is null or empty");
      }
    } catch (e) {
      log("Error retrieving FCM token: $e");
    }
  }

  Future<bool> updateFCMToken(String token) async {
    log("Updating FCM token: $token");
    const url = '$baseUrl/user/refreshFCM';
    String? accessToken = await _authService.getAccessTokenFromStorage();
    String? deviceId = await getDeviceId();
    if (accessToken == null) {
      throw Exception('Access token not available');
    }
    final response = await dio.post(url,
        options: Options(
          headers: {'Authorization': 'Bearer $accessToken'},
        ),
        data: {
          'fcmToken': token,
          'deviceId' : deviceId ?? ""
        });

    if (response.statusCode == 200) {
      log("-----------------Response from updateFCMToken = ${response.data}");
      return response.data == true;
    }
    return false;
  }

  /// Save FCM Token to SharedPreferences
  Future<void> saveToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('fcm_token', token);
      log("FCM Token saved: $token");

      // Set up listener for token refresh
      firebaseMessaging.onTokenRefresh.listen((fcmToken) async {
        log("FCM Token refreshed: $fcmToken");
        await updateFCMToken(fcmToken);
        await prefs.setString('fcm_token', fcmToken);
      }).onError((error) {
        log("FCM token refresh error: $error");
      });
    } catch (e) {
      log("Error saving FCM token: $e");
    }
  }

  /// Request Notification Permission with comprehensive error handling
  Future<bool> requestNotificationPermission() async {
    try {
      NotificationSettings settings = await firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      switch (settings.authorizationStatus) {
        case AuthorizationStatus.authorized:
          log("User granted notification permission");
          return true;
        case AuthorizationStatus.provisional:
          log("User granted provisional notification permission");
          return true;
        case AuthorizationStatus.denied:
          log("User denied notification permission");
          return false;
        default:
          log("Unknown notification permission status");
          return false;
      }
    } catch (e) {
      log("Error requesting notification permission: $e");
      return false;
    }
  }

  /// Set up FCM, notification channels, and token retrieval
  Future<void> setupInteractedMessage() async {
    try {
      bool permissionGranted = await requestNotificationPermission();
      if (permissionGranted) {
        await enableIOSNotifications();
        await initNotificationPlugin();
        log("FCM and notification plugins initialized successfully");

        await getFCMToken();
        registerNotificationListeners();
        FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
          log("Notification opened from background: ${message.data}");
          AndroidNotification? android = message.notification?.android;
          showNotification(message.notification, android, true, message.data);
        });
      } else {
        log("Notifications disabled: Proceeding without FCM setup");
        await SharedPreferences.getInstance().then((prefs) {
          prefs.setBool('notifications_enabled', false);
        });
      }
    } catch (e) {
      log("Error in setupInteractedMessage: $e");
    }
  }

  /// Initialize Local Notification Plugin
  Future<void> initNotificationPlugin() async {
    try {
      channel = androidNotificationChannel();
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel!);

      var androidSettings = const AndroidInitializationSettings('ic_launcher');
      var iOSSettings = const DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true);
      var initSettings =
          InitializationSettings(android: androidSettings, iOS: iOSSettings);

      await flutterLocalNotificationsPlugin.initialize(initSettings);
      log("Local notifications initialized");
    } catch (e) {
      log("Error initializing notification plugin: $e");
    }
  }

  /// Listen for FCM foreground messages
  void registerNotificationListeners() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        log("Foreground notification data received: $message");
        AndroidNotification? android = message.notification?.android;
        showNotification(message.notification, android, true, message.data);
      }
    }).onError((error) {
      log("Error in notification listener: $error");
    });
  }

  /// Show local notification
  void showNotification(RemoteNotification? notification,
      AndroidNotification? android, bool isBackground, Map<String, dynamic> notif) {
    
    flutterLocalNotificationsPlugin.show(
      notification.hashCode,
     notification?.title ?? "New Event",
      notification?.body ?? "You have a new event",
      NotificationDetails(
          android: AndroidNotificationDetails(
            channel!.id,
            channel!.name,
            icon: android?.smallIcon,
            playSound: true,
          ),
          iOS: const DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
              presentBanner: true)),
      payload: notif["id"],
    );
  }

  /// Enable iOS foreground notification options
  Future<void> enableIOSNotifications() async {
    try {
      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
      log("iOS foreground notifications enabled");
    } catch (e) {
      log("Error enabling iOS notifications: $e");
    }
  }

  /// Create Android notification channel
  AndroidNotificationChannel androidNotificationChannel() {
    return const AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      importance: Importance.max,
    );
  }

  Future<String?> getDeviceId() async {
    if (Platform.isIOS) {
      var deviceInfo = DeviceInfoPlugin();
      var iosDeviceInfo = await deviceInfo.iosInfo;
      print("DeviceID == ${iosDeviceInfo.identifierForVendor}");
      return iosDeviceInfo.identifierForVendor; // unique ID on iOS
    } else if (Platform.isAndroid) {
      const androidIdPlugin = AndroidId();
      final pluginDeviceId = await androidIdPlugin.getId();
      print("DeviceID == ${pluginDeviceId}"); // unique ID on Android
      return pluginDeviceId;
    }
    return null;
  }
  
}

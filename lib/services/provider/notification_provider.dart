import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:gark_academy/models/notification_model.dart';
import 'package:gark_academy/services/firebase_service.dart';
import 'package:gark_academy/services/member_service.dart';
import 'package:gark_academy/services/utilities/functions.dart';
import 'package:gark_academy/utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:dio/dio.dart';

class NotificationProvider with ChangeNotifier {
  final MemberService userService = MemberService();
  final PushNotificationService notifService = PushNotificationService();

  List<NotificationModel> _notifications = [];
  WebSocketChannel? _channel;
  final Dio _dio = Dio();
  Timer? _pingTimer;
  bool _isReconnecting = false;
  final firebaseMessaging = FirebaseMessaging.instance;
  List<NotificationModel> get notifications => _notifications;

  void connectWebSocket(String email) {
    _channel = WebSocketChannel.connect(
      Uri.parse('$baseUrlWebSocket/ws?username=$email'),
    );

    _channel!.stream.listen((data) {
      // Filter out ping messages
      if (data == 'Received: {"type":"ping"}') {
        print('Ping message received, ignoring.');
        return;
      }

      try {
        print('Received data: $data');
        List<dynamic> notificationsJson = json.decode(data);
        _notifications = notificationsJson
            .map((json) => NotificationModel.fromJson(json))
            .toList();
        notifyListeners();
      } catch (e) {
        print('Error processing data: $e');
      }
    }, onError: (error) {
      print('WebSocket error: $error');
      _handleConnectionClose(email);
    }, onDone: () {
      print('WebSocket closed');
      _handleConnectionClose(email);
    });

    // Start sending ping messages every 30 seconds to keep the connection alive
    _pingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _channel?.sink.add(json.encode({'type': 'ping'}));
    });
  }

  void _handleConnectionClose(String email) {
    if (!_isReconnecting) {
      _isReconnecting = true;
      _pingTimer?.cancel();
      Future.delayed(const Duration(seconds: 5), () {
        connectWebSocket(email);
        _isReconnecting = false;
      });
    }
  }

  Future<void> markNotificationAsSeen(int id) async {
    final url = '$baseUrl/notification/seen/$id';
    try {
      String? accessToken = await getAccessTokenFromStorage();
      final response = await _dio.get(
        url,
        options: Options(
          headers: {'Authorization': 'Bearer $accessToken'},
        ),
      );
      if (response.statusCode == 200) {
        _notifications
            .firstWhere((notification) => notification.id == id)
            .markAsViewed();
        notifyListeners();
      } else {
        print('Failed to mark notification as seen');
      }
    } catch (e) {
      print('Error marking notification as seen: $e');
    }
  }

  Future<String?> getFcmToken() async {
    try {
      await notifService.getFCMToken();
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString("fcm_token");
    } catch (e) {
      log('Error getFcmToken : $e');
      return "";
    }
  }

  Future<void> deleteNotification(int id) async {
    final url = '$baseUrl/notification/delete/$id';
    try {
      String? accessToken = await getAccessTokenFromStorage();
      final response = await _dio.delete(
        url,
        options: Options(
          headers: {'Authorization': 'Bearer $accessToken'},
        ),
      );
      if (response.statusCode == 200) {
        _notifications.removeWhere((notification) => notification.id == id);
        notifyListeners();
      } else {
        print('Failed to delete notification');
      }
    } catch (e) {
      print('Error deleting notification: $e');
    }
  }

  bool get hasUnseenNotifications {
    return _notifications.any((notification) => !notification.viewed);
  }

  int get unseenNotificationCount {
    return _notifications.where((notification) => !notification.viewed).length;
  }

  void disconnectWebSocket() {
    _pingTimer?.cancel();
    _channel?.sink.close();
  }

  void clearNotifications() {
    _notifications.clear();
    notifyListeners();
  }
}

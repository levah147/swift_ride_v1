// lib/core/services/notification_service.dart

import 'dart:async';
// import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'websocket_service.dart';

class NotificationService {
  final WebSocketService _webSocketService;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  NotificationService(this._webSocketService) {
    _init();
    _listenToWebSocketMessages();
  }

  /// Initialize notification settings
  Future<void> _init() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    const iosSettings = DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _flutterLocalNotificationsPlugin.initialize(initSettings);
  }

  /// Start listening for WebSocket messages and trigger notifications
  void _listenToWebSocketMessages() {
    _webSocketService.messageStream.listen((message) {
      if (message['type'] == 'notification') {
        final title = message['title'] ?? 'New Notification';
        final body = message['body'] ?? '';
        _showLocalNotification(title, body);
      }
    });
  }

  /// Show local notification on the device
  Future<void> _showLocalNotification(String title, String body) async {
    const androidDetails = AndroidNotificationDetails(
      'ride_hailing_channel',
      'Ride Hailing Notifications',
      channelDescription: 'Channel for ride hailing alerts',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );

    const iosDetails = DarwinNotificationDetails();

    const platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _flutterLocalNotificationsPlugin.show(
      0, // You might want to use a unique ID or timestamp
      title,
      body,
      platformDetails,
    );
  }

  /// iOS permission request (usually called on app launch)
  Future<void> requestNotificationPermissions() async {
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }
}

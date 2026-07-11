import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    try {
      const androidSettings =
          AndroidInitializationSettings('@mipmap/launcher_icon');
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );
      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _plugin.initialize(initSettings);
      _initialized = true;
    } catch (e) {
      debugPrint('NotificationService init failed: $e');
    }
  }

  Future<void> showPaymentNotification(String destinationName) async {
    if (!_initialized) await init();
    if (!_initialized) return;

    try {
      const androidDetails = AndroidNotificationDetails(
        'payment_channel',
        'Payment Notifications',
        channelDescription: 'Notifications for payment and ticket updates',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/launcher_icon',
      );
      const details = NotificationDetails(android: androidDetails);

      await _plugin.show(
        0,
        'Payment Successful!',
        'Your ticket for $destinationName has been created.',
        details,
      );
    } catch (e) {
      debugPrint('Failed to show notification: $e');
    }
  }
}

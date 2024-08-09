import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationsServices {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  final AndroidInitializationSettings _androidInitializationSettings = AndroidInitializationSettings('erick');

  void initializeNotifications() async {
    InitializationSettings initializationSettings = InitializationSettings(
      android: _androidInitializationSettings
    );

    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }


  void sendNotification(String title, String body) async {

    AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
        'channelId',
        'channelName',
      color: Colors.red,
      importance: Importance.max,
      priority: Priority.max,
    );

    NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
    );
    
    await _flutterLocalNotificationsPlugin.show(0, title, body, notificationDetails);
    
  }

}
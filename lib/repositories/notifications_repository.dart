import 'dart:async';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:khungulanga_app/api_connection/api_client.dart';
import 'package:khungulanga_app/api_connection/con_options.dart';
import 'package:khungulanga_app/models/notification.dart';
import 'package:path/path.dart';

import '../api_connection/endpoints.dart';
import '../widgets/notification/notifications_page.dart';

@pragma('vm:entry-point')
Future<void> _handleBackgroundMessage(RemoteMessage message) async {
  // Handle background notifications when the app is terminated
  log('Handling background message: ${message.data}');
}
void onNotificationResponse(NotificationResponse details) {
  log(details.payload ?? "New notification");
}

class NotificationRepository {
  final FirebaseMessaging _firebaseMessaging;
  static List<NotificationModel> _notifications = [];
  final Dio _dio = APIClient.dio;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static Stream<List<NotificationModel>>? get notificationsStream =>
      _notificationsStreamController.stream;
  static final _notificationsStreamController =
  StreamController<List<NotificationModel>>.broadcast();

  NotificationRepository() : _firebaseMessaging = FirebaseMessaging.instance {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _handleMessage(message);
    });

    FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);
    //initialize();
  }

  Future<void> _handleMessage(RemoteMessage message) async {
    final notificationJson = message.data;
    log("New Notification: "  + notificationJson.toString());
    //final notification = NotificationModel.fromJson(notificationJson);

    // _notifications.insert(0, notification);
    // _notificationsStreamController.add(_notifications);
    getNotifications();
    showNotification(message.notification?.title ?? "New Notification", message.notification?.body ?? "You have a new notification.");
  }

  void initializeNotificationChannel(BuildContext context) {

    // Handle foreground notifications
    flutterLocalNotificationsPlugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
      onDidReceiveNotificationResponse: (r) {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => NotificationsPage(),
        ));
      },
      onDidReceiveBackgroundNotificationResponse: onNotificationResponse,
    );

  }

  void showNotification(String title, String body) async {
    await _demoNotification(title, body);
  }

  Future<void> _demoNotification(String title, String body) async {
    var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
        'channel_ID', 'channel name', channelDescription: 'channel description',
        importance: Importance.max,
        playSound: true,
        showProgress: true,
        priority: Priority.high,
        ticker: 'test ticker');

    //var iOSChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin
        .show(0, title, body, platformChannelSpecifics, payload: 'test');
  }

  Future<String?> getFCMToken() async {
    String? token;
    try {
      token = await _firebaseMessaging.getToken();
      log('FCM token: $token');
    } catch (e) {
      log('Failed to get FCM token: $e');
    }
    return token;
  }

  void dispose() {
    //_notificationsStreamController.close();
  }

  Future<void> initialize(BuildContext context) async {
    initializeNotificationChannel(context);
    final token = await getFCMToken();
    if (token != null) {
      await _dio.post('$DEVICES_URL/',
          options: postOptions(), data: {'registration_id': token, 'type': 'android'});
    }
    getNotifications();
  }

  Future<List<NotificationModel>> getNotifications() async {
    final response = await _dio.get('$NOTIFICATIONS_URL/',
        options: getOptions());
    final notificationsJson = response.data as List<dynamic>;
    _notifications = notificationsJson
        .map((notificationJson) => NotificationModel.fromJson(notificationJson))
        .toList();
    try {
      _notificationsStreamController.add(_notifications);
    } catch(err) {
      log(err.toString());
    }
    return _notifications;
  }

  Future<NotificationModel> getNotification(int id) async {
    final response = await _dio.get('$NOTIFICATIONS_URL/$id/',
        options: getOptions());
    final notificationJson = response.data as Map<String, dynamic>;
    final notification = NotificationModel.fromJson(notificationJson);
    return notification;
  }

  Future<NotificationModel> saveNotification(NotificationModel notification) async {
    final response = await _dio.post('$NOTIFICATIONS_URL/',
        options: postOptions(), data: notification.toJson());

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('Failed to create notification');
    } else {
      final notificationJson = response.data as Map<String, dynamic>;
      log(notificationJson.toString());
      final createdNotification =
      NotificationModel.fromJson(notificationJson);
      return createdNotification;
    }
  }

  Future<NotificationModel> updateNotification(NotificationModel notification) async {
    final response = await _dio.put('$NOTIFICATIONS_URL/${notification.id}/',
        options: putOptions(), data: notification.toJson());

    if (response.statusCode != 200) {
      throw Exception('Failed to update notification');
    } else {
      final notificationJson = response.data as Map<String, dynamic>;
      final updatedNotification =
      NotificationModel.fromJson(notificationJson);
      return updatedNotification;
    }
  }

  Future<void> deleteNotification(int id) async {
    final response = await _dio.delete('$NOTIFICATIONS_URL/$id/',
        options: deleteOptions());

    if (response.statusCode != 204) {
      throw Exception('Failed to delete notification');
    }
  }

  bool hasUnread() {
    return _notifications.any((element) => !element.isRead);
  }

  bool hasUnreadDiagnosisFeedback() {
    return _notifications.any((element) => !element.isRead && element.relatedName == "Diagnosis");
  }
}

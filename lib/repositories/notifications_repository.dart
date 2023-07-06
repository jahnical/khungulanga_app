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

/// Handles background messages for Firebase Cloud Messaging (FCM).
Future<void> _handleBackgroundMessage(RemoteMessage message) async {
  // Handle background notifications when the app is terminated
  log('Handling background message: ${message.data}');
}

/// Handles notification responses when the app is in the foreground.
void onNotificationResponse(NotificationResponse details) {
  log(details.payload ?? "New notification");
}

/// Repository for managing notification-related data and operations.
class NotificationRepository {
  final FirebaseMessaging _firebaseMessaging;
  static List<NotificationModel> _notifications = [];
  final Dio _dio = APIClient.dio;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  /// Retrieves the stream of notifications.
  static Stream<List<NotificationModel>>? get notificationsStream =>
      _notificationsStreamController.stream;
  static final _notificationsStreamController =
  StreamController<List<NotificationModel>>.broadcast();

  /// Constructs a new instance of [NotificationRepository].
  NotificationRepository() : _firebaseMessaging = FirebaseMessaging.instance {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _handleMessage(message);
    });

    FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);
  }

  /// Handles a new FCM message received.
  Future<void> _handleMessage(RemoteMessage message) async {
    final notificationJson = message.data;
    log("New Notification: "  + notificationJson.toString());
    getNotifications();
    showNotification(message.notification?.title ?? "New Notification", message.notification?.body ?? "You have a new notification.");
  }

  /// Initializes the notification channel.
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

  /// Shows a local notification with the provided title and body.
  void showNotification(String title, String body) async {
    await _demoNotification(title, body);
  }

  /// Demonstrates a local notification with the provided title and body.
  Future<void> _demoNotification(String title, String body) async {
    var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
        'channel_ID', 'channel name', channelDescription: 'channel description',
        importance: Importance.max,
        playSound: true,
        showProgress: true,
        priority: Priority.high,
        ticker: 'test ticker');

    var platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin
        .show(0, title, body, platformChannelSpecifics, payload: 'test');
  }

  /// Retrieves the FCM token.
  Future<String?> getFCMToken() async {
    String? token;
    try {
      token = await _firebaseMessaging.getToken();
      log('FCM token: $token');
    } catch (e) {
      log('Failedto get FCM token: $e');
    }
    return token;
  }

  /// Disposes of resources used by the repository.
  void dispose() {
    //_notificationsStreamController.close();
  }

  /// Initializes the notification repository.
  Future<void> initialize(BuildContext context) async {
    initializeNotificationChannel(context);
    final token = await getFCMToken();
    if (token != null) {
      await _dio.post('$DEVICES_URL/',
          options: postOptions(), data: {'registration_id': token, 'type': 'android'});
    }
    getNotifications();
  }

  /// Retrieves a list of notifications.
  ///
  /// Returns a list of [NotificationModel] objects representing the notifications.
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

  /// Retrieves a notification by its ID.
  ///
  /// [id] represents the ID of the notification.
  /// Returns a [NotificationModel] object representing the notification.
  Future<NotificationModel> getNotification(int id) async {
    final response = await _dio.get('$NOTIFICATIONS_URL/$id/',
        options: getOptions());
    final notificationJson = response.data as Map<String, dynamic>;
    final notification = NotificationModel.fromJson(notificationJson);
    return notification;
  }

  /// Saves a new notification.
  ///
  /// [notification] represents the notification to be saved.
  /// Returns the created [NotificationModel] object.
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

  /// Updates an existing notification.
  ///
  /// [notification] represents the updated notification.
  /// Returns the updated [NotificationModel] object.
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

  /// Deletes a notification by its ID.
  ///
  /// [id] represents the ID of the notification to be deleted.
  Future<void> deleteNotification(int id) async {
    final response = await _dio.delete('$NOTIFICATIONS_URL/$id/',
        options: deleteOptions());

    if (response.statusCode != 204) {
      throw Exception('Failed to delete notification');
    }
  }

  /// Checks if there are any unread notifications.
  ///
  /// Returns true if there are unread notifications, false otherwise.
  bool hasUnread() {
    return _notifications.any((element) => !element.isRead);
  }

  /// Checks if there are any unread diagnosis feedback notifications.
  ///
  /// Returns true if there are unread diagnosis feedback notifications, falseotherwise.
  bool hasUnreadDiagnosisFeedback() {
    return _notifications.any((element) => !element.isRead && element.relatedName == "Diagnosis");
  }
}

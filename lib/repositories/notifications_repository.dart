import 'dart:async';
import 'dart:convert';

import 'package:khungulanga_app/models/notification.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class NotificationRepository {
  static const String serverUrl = 'ws://your-websocket-server-url'; // Replace with your WebSocket server URL

  final WebSocketChannel _channel;
  final List<NotificationModel> _notifications = [];

  Stream<List<NotificationModel>>? get notificationsStream => _notificationsStreamController.stream;
  final _notificationsStreamController = StreamController<List<NotificationModel>>.broadcast();

  NotificationRepository() : _channel = IOWebSocketChannel.connect(serverUrl) {
    _channel.stream.listen((dynamic message) {
      _handleMessage(message);
    });
  }

  void _handleMessage(dynamic message) {
    // Assuming the message received is a JSON representation of a notification
    final notificationJson = jsonDecode(message);
    final notification = NotificationModel.fromJson(notificationJson);

    _notifications.insert(0, notification);
    _notificationsStreamController.add(_notifications);
  }

  void dispose() {
    _channel.sink.close();
    _notificationsStreamController.close();
  }
}
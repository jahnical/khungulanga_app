import 'package:intl/intl.dart';
import 'user.dart';

/// Model class for managing notifications.
class NotificationModel {
  final int id;
  final String title;
  final String message;
  final DateTime timestamp;
  bool isRead;
  final String route;
  final int? relatedId;
  final String? relatedName;
  final User? user;

  /// Constructs a new instance of the NotificationModel class.
  /// [id] is the ID of the notification.
  /// [title] is the title of the notification.
  /// [message] is the message of the notification.
  /// [timestamp] is the timestamp of the notification.
  /// [isRead] is whether the notification is read or not.
  /// [route] is the route of the notification.
  /// [relatedId] is the ID of the related object.
  /// [relatedName] is the name of the related object.
  /// [user] is the user of the notification.
  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.isRead,
    required this.route,
    this.relatedId,
    this.relatedName,
    this.user,
  });

  /// Constructs a NotificationModel object from a JSON map.
  /// [json] is the JSON map representing the NotificationModel.
  /// Returns a NotificationModel object.
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String,
      message: json['message'] as String,
      timestamp: DateTime.parse(json['timestamp']),
      isRead: json['is_read'] as bool? ?? false,
      route: json['route'] as String? ?? '',
      relatedId: json['related_id'] as int?,
      relatedName: json['related_name'] as String?,
      user: json['user'] != null? User.fromJson(json['user']) : null,
    );
  }

  /// Converts the NotificationModel object to a JSON map.
  /// Returns a JSON map representing the NotificationModel.
  Map<String, dynamic> toJson() {
    final dateFormat = DateFormat('yyyy-MM-ddTHH:mm:ss');
    return {
      'id': id,
      'title': title,
      'message': message,
      'timestamp': dateFormat.format(timestamp),
      'is_read': isRead,
      'route': route,
      'related_id': relatedId,
      'related_name': relatedName,
      'user': user?.toJson(),
    };
  }
}
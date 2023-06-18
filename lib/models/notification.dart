import 'package:intl/intl.dart';
import 'user.dart';

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
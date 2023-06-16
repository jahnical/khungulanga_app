import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:khungulanga_app/models/notification.dart';

class NotificationsPage extends StatefulWidget {
  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  List<NotificationModel> notifications = [
    NotificationModel(
      id: 1,
      title: 'New Message',
      message: 'You have a new message.',
      timestamp: DateTime.now(),
      isRead: false,
      route: '/message', user: null,
    ),
    NotificationModel(
      id: 2,
      title: 'Event Reminder',
      message: 'Don\'t forget about the upcoming event.',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      isRead: true,
      route: '/event',
    ),
    // Add more sample notifications here
  ];

  bool isAllRead = false;

  void markAllNotificationsAsRead() {
    setState(() {
      notifications.forEach((notification) {
        notification.isRead = true;
      });
      isAllRead = true;
    });
  }

  void markNotificationAsRead(NotificationModel notification) {
    setState(() {
      notification.isRead = true;
    });
  }

  void clearAllNotifications() {
    setState(() {
      notifications.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    notifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    final groupedNotifications = groupNotificationsByDate(notifications);

    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
        actions: [
          if (notifications.isNotEmpty)
            IconButton(
              icon: Icon(Icons.clear_all),
              onPressed: markAllNotificationsAsRead,
            ),
        ],
      ),
      body: notifications.isEmpty
          ? Center(
        child: Text('No notifications.'),
      )
          : ListView.builder(
        itemCount: groupedNotifications.length,
        itemBuilder: (context, index) {
          final group = groupedNotifications[index];
          final groupDate = group['date'];
          final groupNotifications = group['notifications'];
          final isLastGroup = index == groupedNotifications.length - 1;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  DateFormat('EEEE, MMM d').format(groupDate),
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: ClampingScrollPhysics(),
                itemCount: groupNotifications.length,
                itemBuilder: (context, index) {
                  final notification = groupNotifications[index];
                  final isLastNotification =
                      index == groupNotifications.length - 1;
                  final formattedTime =
                  DateFormat.jm().format(notification.timestamp);

                  return Column(
                    children: [
                      Card(
                        elevation: 2,
                        margin: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.all(8),
                          onTap: () {
                            markNotificationAsRead(notification);
                            // Handle navigation to notification route
                            Navigator.pushNamed(
                                context, notification.route);
                          },
                          title: Text(
                            notification.title,
                            style: TextStyle(
                              fontWeight: notification.isRead
                                  ? FontWeight.normal
                                  : FontWeight.bold,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                notification.message,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                formattedTime,
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          trailing: !notification.isRead
                              ? Icon(
                            Icons.circle,
                            color: Colors.blueAccent,
                            size: 16,
                          )
                              : null,
                        ),
                      ),
                      if (!isLastNotification)
                        Divider(
                          height: 2,
                          indent: 72,
                        ),
                    ],
                  );
                },
              ),
              if (!isLastGroup) Divider(height: 24),
            ],
          );
        },
      ),
    );
  }

  List<Map<String, dynamic>> groupNotificationsByDate(
      List<NotificationModel> notifications) {
    final groupedMap = <String, List<NotificationModel>>{};
    final groupedNotifications = <Map<String, dynamic>>[];

    for (final notification in notifications) {
      final date = DateFormat('yyyy-MM-dd').format(notification.timestamp);
      if (groupedMap.containsKey(date)) {
        groupedMap[date]!.add(notification);
      } else {
        groupedMap[date] = [notification];
      }
    }

    groupedMap.forEach((date, notifications) {
      final group = {
        'date': DateTime.parse(date),
        'notifications': notifications,
      };
      groupedNotifications.add(group);
    });

    return groupedNotifications;
  }
}

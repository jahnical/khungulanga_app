import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:khungulanga_app/models/notification.dart';
import 'package:khungulanga_app/repositories/notifications_repository.dart';
import 'package:khungulanga_app/widgets/appointment/appointments_page.dart';
import 'package:khungulanga_app/widgets/diagnosis/derm_diagnosis_page.dart';

import '../../repositories/appointment_repository.dart';
import '../../repositories/diagnosis_repository.dart';
import '../../repositories/user_repository.dart';
import '../diagnosis/diagnosis_page.dart';

class NotificationsPage extends StatefulWidget {
  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  late NotificationRepository _notificationRepository;
  List<NotificationModel> notifications = [];
  bool isLoading = false;
  bool isError = false;

  @override
  void initState() {
    super.initState();
    _notificationRepository = RepositoryProvider.of<NotificationRepository>(context);
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      isLoading = true;
      isError = false;
    });

    try {
      notifications = await _notificationRepository.getNotifications();
    } catch (error) {
      log(error.toString());
      setState(() {
        isError = true;
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void markAllNotificationsAsRead() {
    setState(() {
      notifications.forEach((notification) {
        notification.isRead = true;
        _notificationRepository.updateNotification(notification);
      });
    });
  }

  void markNotificationAsRead(NotificationModel notification) {
    setState(() {
      notification.isRead = true;
      _notificationRepository.updateNotification(notification);
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
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadNotifications,
          ),
        ],
      ),
      body: isLoading
          ? Center(
        child: CircularProgressIndicator(),
      )
          : isError
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Failed to load notifications.'),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadNotifications,
              child: Text('Retry'),
            ),
          ],
        ),
      )
          : notifications.isEmpty
          ? Center(
        child: Text('No notifications.'),
      )
          : RefreshIndicator(
            onRefresh: _loadNotifications,
            child: ListView.builder(
        itemCount: groupedNotifications.length,
        itemBuilder: (context, index) {
            final group = groupedNotifications[index];
            final groupDate = group['date'];
            final groupNotifications = group['notifications'];
            final isLastGroup =
                index == groupedNotifications.length - 1;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    DateFormat('EEEE, MMM d')
                        .format(groupDate),
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
                    final notification =
                    groupNotifications[index];
                    final isLastNotification =
                        index == groupNotifications.length - 1;
                    final formattedTime = DateFormat.jm()
                        .format(notification.timestamp);

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
                              notificationTaped(notification, context);
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
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
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
          ),
    );
  }

  List<Map<String, dynamic>> groupNotificationsByDate(
      List<NotificationModel> notifications) {
    final groupedMap = <String, List<NotificationModel>>{};
    final groupedNotifications = <Map<String, dynamic>>[];

    for (final notification in notifications) {
      final date =
      DateFormat('yyyy-MM-dd').format(notification.timestamp);
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

  @override
  void dispose() {
    _notificationRepository.dispose();
    super.dispose();
  }

  Future<void> notificationTaped(NotificationModel notification, BuildContext context) async {
    markNotificationAsRead(notification);
    if (notification.relatedName == 'Diagnosis') {
      final repo = RepositoryProvider.of<DiagnosisRepository>(context);
      final userRepo = RepositoryProvider.of<UserRepository>(context);
      final diagnosis = repo.getDiagnosis(notification.relatedId!);
      if (userRepo.patient == null) {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => DermDiagnosisPage(diagnosis: diagnosis)));
      } else {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => DiagnosisPage(diagnosis: diagnosis)));
      }

    } else if (notification.relatedName == 'Appointment') {
      final repo = RepositoryProvider.of<AppointmentRepository>(context);

      /*setState(() {
        isLoading = true;
      });*/
      try {

        final appointment = await repo.getAppointment(notification.relatedId!);
        Navigator.of(context).push(
            MaterialPageRoute(
                builder: (context) => AppointmentsPage(completed: appointment.done, cancelled: appointment.patientCancelled != null || appointment.dermatologistCancelled != null)
            ));
      } catch (error) {
        log(error.toString());
      } finally {
        setState(() {
          isLoading = false;
        });
      }

    }
  }
}

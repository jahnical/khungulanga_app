import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:khungulanga_app/models/appointment.dart';
import 'package:khungulanga_app/repositories/appointment_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:khungulanga_app/repositories/user_repository.dart';
import 'package:khungulanga_app/widgets/refreshable_widget.dart';

import '../../repositories/notifications_repository.dart';
import 'appointment_detail_page.dart';

class AppointmentList extends RefreshableWidget {
  final AppointmentRepository appointmentRepository = AppointmentRepository();
  final bool completed;
  bool cancelled = false;

  AppointmentList({required this.completed, this.cancelled = false});

  @override
  _AppointmentListState createState() => _AppointmentListState();
}

class _AppointmentListState extends RefreshableWidgetState<AppointmentList> {
  Future<List<Appointment>> _appointmentsFuture = Future.value([]);
  bool _isUpdating = false;
  bool _isPatient = false;

  @override
  void initState() {
    super.initState();
    _loadAppointments();

    final notRepo = RepositoryProvider.of<NotificationRepository>(context);
    NotificationRepository.notificationsStream?.listen((event) {
      if (notRepo.hasUnread()) _loadAppointments();
    });
  }

  void _loadAppointments() {
    setState(() {
      _appointmentsFuture = widget.appointmentRepository.getAppointments(
        widget.completed,
        cancelled: widget.cancelled,
      );
      _isPatient = RepositoryProvider.of<UserRepository>(context).patient != null;
    });
  }

  List<Widget> _buildAppointmentList(List<Appointment> appointments) {
    List<Widget> appointmentWidgets = [];

    DateTime currentDate = DateTime(0);
    DateFormat dateFormat = DateFormat('MMMM dd, yyyy');

    for (int i = 0; i < appointments.length; i++) {
      final appointment = appointments[i];
      final appointmentDate = appointment.appoTime ?? DateTime.now();

      if (appointmentDate.difference(currentDate).inDays > 0) {
        // Display the date section
        currentDate = appointmentDate;

        String formattedDate = dateFormat.format(currentDate);
        appointmentWidgets.add(
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              formattedDate,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        );
      }

      appointmentWidgets.add(
        Column(
          children: [
            ListTile(
              leading: const Icon(
                Icons.calendar_today_outlined,
                color: Colors.green,
              ),
              tileColor: Colors.grey[50],
              title: Text(
                !_isPatient
                    ? 'Client: ${appointment.patient?.user?.firstName} ${appointment.patient?.user?.lastName}'
                    : 'Dermatologist: ${appointment.dermatologist.user.firstName} ${appointment.dermatologist.user.lastName}',
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
              subtitle: Text(
                'Time: ${DateFormat('h:mm a').format(appointmentDate)}',
                style: TextStyle(
                  fontSize: 14,
                ),
              ),
              trailing: _isUpdating
                  ? CircularProgressIndicator()
                  : appointment.done || widget.cancelled
                  ? IconButton(
                icon: Icon(Icons.remove_circle),
                color: Colors.red,
                onPressed: () {
                  showRemoveConfirmationDialog(appointment);
                },
              )
                  : IconButton(
                icon: Icon(Icons.cancel),
                color: Colors.orange,
                onPressed: () {
                  showCancelConfirmationDialog(appointment);
                },
              ),
              onTap: () {
                // Handle appointment tap
                // You can navigate to the appointment details page or perform other actions
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        AppointmentDetailPage(appointment: appointment),
                  ),
                );
              },
            ),
            const Divider(height: 0),
          ],
        ),
      );
    }

    return appointmentWidgets;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Appointment>>(
      future: _appointmentsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: ${snapshot.error}'),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadAppointments,
                child: Text('Retry'),
              ),
            ],
          );
        } else if (snapshot.hasData) {
          final appointments = snapshot.data!;

          if (appointments.isEmpty) {
            final appointmentType =
            widget.cancelled ? "Cancelled" : widget.completed ? 'Completed' : 'Scheduled';
            final message = 'No $appointmentType Appointments.';

            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    message,
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
            );
          }

          return ListView(
            children: _buildAppointmentList(appointments),
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Future<void> showRemoveConfirmationDialog(Appointment appointment) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Remove Appointment'),
          content: Text('Are you sure you want to remove this appointment?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await updateAppointment(appointment, true);
              },
              child: Text('Remove'),
            ),
          ],
        );
      },
    );
  }

  Future<void> showCancelConfirmationDialog(Appointment appointment) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Cancel Appointment'),
          content: Text('Are you sure you want to cancel this appointment?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('No'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await updateAppointment(appointment, false);
              },
              child: Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  Future<void> updateAppointment(Appointment appointment, bool isRemove) async {
    setState(() {
      _isUpdating = true;
    });

    try {
      if (isRemove) {
        if (_isPatient) {
          appointment.patientRemoved = DateTime.now();
        } else {
          appointment.dermatologistRemoved = DateTime.now();
        }
      } else {
        appointment.slot = null;
        if (_isPatient) {
          appointment.patientCancelled = DateTime.now();
        } else {
          appointment.dermatologistCancelled = DateTime.now();
        }
      }

      await widget.appointmentRepository.updateAppointment(appointment);

      setState(() {
        _isUpdating = false;
        _appointmentsFuture = widget.appointmentRepository.getAppointments(
          widget.completed,
          cancelled: widget.cancelled,
        );
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Appointment updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (error) {
      setState(() {
        _isUpdating = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update appointment'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Future<void>? refresh() {
    _loadAppointments();
  }
}

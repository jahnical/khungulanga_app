import 'package:flutter/material.dart';
import 'package:khungulanga_app/models/appointment.dart';
import 'package:khungulanga_app/repositories/appointment_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/home_navigation_bloc/home_navigation_bloc.dart';
import 'appointment_detail_page.dart';

class AppointmentList extends StatefulWidget {
  final AppointmentRepository appointmentRepository = AppointmentRepository();
  final bool completed;

  AppointmentList({required this.completed});

  @override
  _AppointmentListState createState() => _AppointmentListState();
}

class _AppointmentListState extends State<AppointmentList> {
  Future<List<Appointment>> _appointmentsFuture = Future.value([]);

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  void _loadAppointments() {
    setState(() {
      _appointmentsFuture =
          widget.appointmentRepository.getAppointments(widget.completed);
    });
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
            widget.completed ? 'Completed' : 'Scheduled';
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

          return ListView.builder(
            itemCount: appointments.length,
            itemBuilder: (context, index) {
              final appointment = appointments[index];

              return Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.calendar_today_outlined, color: Colors.green,),
                    tileColor: Colors.grey[50],
                    title: Text(
                      'Patient: ${appointment.patient?.user?.firstName} ${appointment.patient?.user?.lastName}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text(
                      'Time: ${appointment.appoTime}',
                      style: TextStyle(
                        fontSize: 14,
                      ),
                    ),
                    trailing: appointment.done
                        ? Icon(
                      Icons.check_circle,
                      color: Colors.green,
                    )
                        : Icon(
                      Icons.schedule,
                      color: Colors.orange,
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
              );
            },
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}

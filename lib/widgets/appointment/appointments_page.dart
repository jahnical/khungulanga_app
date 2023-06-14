import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:khungulanga_app/models/appointment.dart';
import 'package:khungulanga_app/repositories/appointment_repository.dart';

import '../../blocs/home_navigation_bloc/home_navigation_bloc.dart';
import 'appointment_detail_page.dart';

class AppointmentsPage extends StatefulWidget {
  final AppointmentRepository appointmentRepository = AppointmentRepository();

  final bool completed;

  AppointmentsPage({Key? key, required this.completed}) : super(key: key);

  @override
  _AppointmentsPageState createState() => _AppointmentsPageState();
}

class _AppointmentsPageState extends State<AppointmentsPage> {
  Future<List<Appointment>> _appointmentsFuture = Future.value([]);

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  void _loadAppointments() {
    setState(() {
      _appointmentsFuture = widget.appointmentRepository.getAppointments(widget.completed);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.completed ? "Completed" : "Scheduled"} Appointments')),
      body: FutureBuilder<List<Appointment>>(
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
              final appointmentType = widget.completed ? 'Completed' : 'Scheduled';
              final message = 'No $appointmentType Appointments.';

              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      message,
                      style: TextStyle(fontSize: 18),
                    ),
                    SizedBox(height: 16),
                    if (!widget.completed)
                      ElevatedButton(
                        onPressed: () {
                          context.read<HomeNavigationBloc>().add(NavigateToDermatologists());
                          Navigator.of(context).pop();
                        },
                        child: Text('Book an Appointment'),
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
                      leading: const Icon(Icons.calendar_today_outlined),
                      tileColor: Colors.grey[50],
                      title: Text(
                        'Dermatologist: ${appointment.dermatologist.user.firstName} ${appointment.dermatologist.user.lastName}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Text(
                        'Appointment Time: ${appointment.appoTime}',
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
                            builder: (context) => AppointmentDetailPage(appointment: appointment),
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
      ),
    );
  }
}

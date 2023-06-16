import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:khungulanga_app/models/appointment.dart';
import 'package:khungulanga_app/repositories/user_repository.dart';

import '../diagnosis/diagnosis_page.dart';
import '../profile/derm_profile.dart';

class AppointmentDetailPage extends StatelessWidget {
  final Appointment appointment;

  AppointmentDetailPage({required this.appointment});

  void _cancelAppointment(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Cancel Appointment'),
          content: Text('Are you sure you want to cancel this appointment?'),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Confirm'),
              onPressed: () {
                // Perform cancellation logic here
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _markAsDone(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Mark Appointment as Done'),
          content: Text('Are you sure you want to mark this appointment as done?'),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Confirm'),
              onPressed: () {
                // Perform mark as done logic here
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        title: Text('Appointment Details'),
        actions: [
          IconButton(
            icon: Icon(Icons.cancel),
            onPressed: () {
              _cancelAppointment(context);
            },
          ),
          IconButton(
            icon: Icon(Icons.done),
            onPressed: () {
              _markAsDone(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16.0),
            if (RepositoryProvider.of<UserRepository>(context).dermatologist == null)
              AppointmentDetailCard(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) {
                    return DermatologistProfilePage(dermatologist: appointment.dermatologist,);
                  }));
                },
                title: 'Dermatologist',
                icon: Icons.person,
                content: '${appointment.dermatologist.user.firstName} ${appointment.dermatologist.user.lastName}',
              ),
            if (RepositoryProvider.of<UserRepository>(context).patient == null)
              AppointmentDetailCard(
                title: 'Patient',
                icon: Icons.person,
                content: '${appointment.patient?.user?.firstName} ${appointment.patient?.user?.lastName}',
              ),
            SizedBox(height: 8.0),
            AppointmentDetailCard(
              title: 'Appointment Date',
              icon: Icons.calendar_today,
              content: appointment.appoTime != null
                  ? DateFormat('MMM d, yyyy h:mm').format(appointment.appoTime!)
                  : 'N/A',
            ),
            SizedBox(height: 8.0),
            AppointmentStatusCard(
              appointment: appointment,
            ),
            SizedBox(height: 8.0),
            AppointmentDetailCard(
              title: 'Healthy Center',
              icon: Icons.location_pin,
              content: '${appointment.dermatologist.clinic.name} Clinic',
            ),
            SizedBox(height: 8.0),
            AppointmentDetailCard(
              title: 'Hourly Cost',
              icon: Icons.money,
              content: '\$${appointment.dermatologist.hourlyRate}',
            ),
            SizedBox(height: 8.0),
            AppointmentDetailCard(
              onTap: () {
                if (appointment.diagnosis != null) {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => DiagnosisPage(
                      diagnosis: appointment.diagnosis!,
                      fromAppointment: true,
                    ),
                  ));
                }
              },
              title: 'Diagnosis',
              icon: Icons.local_hospital,
              content: appointment.diagnosis?.predictions[0].disease.name.toUpperCase() ?? 'N/A',
            ),
          ],
        ),
      ),
    );
  }
}

class AppointmentDetailCard extends StatelessWidget {
  final String title;
  final IconData? icon;
  final String content;
  final Null Function()? onTap;

  AppointmentDetailCard({
    required this.title,
    this.icon,
    required this.content,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        //color: Colors.blue[50],
        elevation: 4.0,
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8.0),
              if (icon != null)
                Row(
                  children: [
                    Icon(icon, size: 24),
                    SizedBox(width: 8.0),
                    Text(
                      content,
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              if (icon == null)
                Text(
                  content,
                  style: TextStyle(fontSize: 16),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class AppointmentStatusCard extends StatelessWidget {
  final Appointment appointment;

  AppointmentStatusCard({required this.appointment});

  @override
  Widget build(BuildContext context) {
    return Card(
      //color: Colors.blue[50],
      elevation: 4.0,
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Status',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.0),
            Row(
              children: [
                Icon(
                  appointment.done ? Icons.check_circle : Icons.schedule,
                  color: appointment.done ? Colors.green : Colors.orange,
                  size: 24,
                ),
                SizedBox(width: 8.0),
                Text(
                  appointment.done ? 'Completed' : 'Scheduled',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

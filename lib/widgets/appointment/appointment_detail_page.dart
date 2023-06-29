import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:khungulanga_app/models/appointment.dart';
import 'package:khungulanga_app/repositories/appointment_repository.dart';
import 'package:khungulanga_app/repositories/user_repository.dart';

import '../diagnosis/diagnosis_page.dart';
import '../profile/derm_profile.dart';

class AppointmentDetailPage extends StatefulWidget {
  final Appointment appointment;

  AppointmentDetailPage({required this.appointment});

  @override
  _AppointmentDetailPageState createState() => _AppointmentDetailPageState();
}

class _AppointmentDetailPageState extends State<AppointmentDetailPage> {
  bool _isLoading = false;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Future<void> _cancelAppointment(BuildContext context) async {
    final confirmed = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Cancel Appointment'),
          content: Text('Are you sure you want to cancel this appointment?'),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: Text('Confirm'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );

    if (confirmed != null && confirmed) {
      try {
        setState(() {
          _isLoading = true;
        });

        final _isPatient = RepositoryProvider.of<UserRepository>(context).patient != null;
        widget.appointment.slot = null;
        if (_isPatient)
          widget.appointment.patientCancelled = DateTime.now();
        else
          widget.appointment.dermatologistCancelled = DateTime.now();

        await RepositoryProvider.of<AppointmentRepository>(context).updateAppointment(widget.appointment);

        setState(() {
          _isLoading = false;
        });

        _showSnackBar(context, 'Appointment cancelled successfully');

        Navigator.of(context).pop();
      } catch (error) {
        setState(() {
          _isLoading = false;
        });

        _showSnackBar(context, 'An error occurred while cancelling the appointment');
      }
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _markAsDone(BuildContext context) async {
    final confirmed = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Mark Appointment as Done'),
          content: Text('Are you sure you want to mark this appointment as done?'),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: Text('Confirm'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );

    if (confirmed != null && confirmed) {
      try {
        setState(() {
          _isLoading = true;
        });

        widget.appointment.done = true;
        await RepositoryProvider.of<AppointmentRepository>(context).updateAppointment(widget.appointment);

        setState(() {
          _isLoading = false;
        });

        _showSnackBar(context, 'Appointment marked as done');

        Navigator.of(context).pop();
      } catch (error) {
        setState(() {
          _isLoading = false;
        });

        _showSnackBar(context, 'An error occurred while marking the appointment as done');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        title: Text('Appointment Details'),
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
                    return DermatologistProfilePage(dermatologist: widget.appointment.dermatologist,);
                  }));
                },
                title: 'Dermatologist',
                icon: Icons.person,
                content: '${widget.appointment.dermatologist.user.firstName} ${widget.appointment.dermatologist.user.lastName}',
              ),
            if (RepositoryProvider.of<UserRepository>(context).patient == null)
              AppointmentDetailCard(
                title: 'Patient',
                icon: Icons.person,
                content: '${widget.appointment.patient?.user?.firstName} ${widget.appointment.patient?.user?.lastName}',
              ),
            SizedBox(height: 8.0),
            AppointmentDetailCard(
              title: 'Appointment Date',
              icon: Icons.calendar_today,
              content: widget.appointment.appoTime != null
                  ? DateFormat('MMM d, yyyy h:mm').format(widget.appointment.appoTime!)
                  : 'N/A',
            ),
            SizedBox(height: 8.0),
            AppointmentStatusCard(
              appointment: widget.appointment,
            ),
            SizedBox(height: 8.0),
            AppointmentDetailCard(
              title: 'Healthy Center',
              icon: Icons.location_pin,
              content: '${widget.appointment.dermatologist.clinic.name} Clinic',
            ),
            SizedBox(height: 8.0),
            AppointmentDetailCard(
              title: 'Hourly Cost',
              icon: Icons.money,
              content: '\$${widget.appointment.dermatologist.hourlyRate}',
            ),
            SizedBox(height: 8.0),
            AppointmentDetailCard(
              onTap: () {
                if (widget.appointment.diagnosis != null) {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => DiagnosisPage(
                      diagnosis: widget.appointment.diagnosis!,
                      fromAppointment: true,
                    ),
                  ));
                }
              },
              title: 'Diagnosis',
              icon: Icons.local_hospital,
              content: widget.appointment.diagnosis == null
                  ? 'N/A'
                  : widget.appointment.diagnosis!.predictions.isNotEmpty
                  ? widget.appointment.diagnosis!.predictions[0].disease.name
                  : "No Disease",
            ),

            const SizedBox(height: 16),
            if (RepositoryProvider.of<UserRepository>(context).patient == null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: ElevatedButton(
                  onPressed: _isLoading ? null : () => _markAsDone(context),
                  child: const Text('Mark as Done'),
                  style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 54)
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: _isLoading ? null : () => _cancelAppointment(context),
                  style: ElevatedButton.styleFrom(
                      primary: Colors.redAccent,
                      minimumSize: Size(double.infinity, 54)
                  ),
                  child: const Text('Cancel Appointment'),
                ),
              ),
            const SizedBox(height: 16),
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

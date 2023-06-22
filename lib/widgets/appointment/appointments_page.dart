import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:khungulanga_app/models/appointment.dart';
import 'package:khungulanga_app/repositories/appointment_repository.dart';
import 'package:khungulanga_app/repositories/user_repository.dart';

import '../../blocs/home_navigation_bloc/home_navigation_bloc.dart';
import 'appointment_detail_page.dart';
import 'appointments_list.dart';

class AppointmentsPage extends StatefulWidget {
  final AppointmentRepository appointmentRepository = AppointmentRepository();

  final bool completed;
  final bool cancelled;

  AppointmentsPage({Key? key, required this.completed, this.cancelled = false})
      : super(key: key);

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
      _appointmentsFuture =
          widget.appointmentRepository.getAppointments(widget.completed, cancelled: widget.cancelled);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.completed ? "Completed" : widget.cancelled? "Cancelled" : "Scheduled"} Appointments'),
      ),
      body: AppointmentList(completed: widget.completed, cancelled: widget.cancelled),
    );
  }
}
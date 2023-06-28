import 'package:flutter/material.dart';
import 'package:khungulanga_app/repositories/appointment_repository.dart';
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
  late AppointmentList list;

  @override
  void initState() {
    super.initState();
    list = AppointmentList(completed: widget.completed, cancelled: widget.cancelled);
  }

  void _loadAppointments() {
    list.refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.completed ? "Completed" : widget.cancelled? "Cancelled" : "Scheduled"} Appointments'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadAppointments,
          ),
        ]
      ),
      body: RefreshIndicator(onRefresh: () async { return _loadAppointments(); },
      child: list),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:khungulanga_app/repositories/appointment_repository.dart';
import 'appointments_list.dart';

class AppointmentsPage extends StatefulWidget {
  final AppointmentRepository appointmentRepository = AppointmentRepository();

  final bool completed;
  final bool cancelled;

  /// Constructs an instance of [AppointmentsPage].
  ///
  /// [completed] specifies whether to display completed appointments.
  /// [cancelled] specifies whether to display cancelled appointments (default is false).
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
    // Initialize the appointment list with the completed and cancelled flags.
    list = AppointmentList(completed: widget.completed, cancelled: widget.cancelled);
  }

  /// Loads the appointments by refreshing the list.
  void _loadAppointments() {
    list.refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Set the title based on the completed and cancelled flags.
          title: Text('${widget.completed ? "Completed" : widget.cancelled? "Cancelled" : "Scheduled"} Appointments'),
          actions: [
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: _loadAppointments,
            ),
          ]
      ),
      body: RefreshIndicator(
        // Configure the RefreshIndicator with the _loadAppointments function as the refresh callback.
        onRefresh: () async { return _loadAppointments(); },
        child: list, // Display the appointment list.
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:khungulanga_app/models/appointment.dart';
import 'package:khungulanga_app/repositories/appointment_repository.dart';
import 'package:khungulanga_app/widgets/appointment/appointment_detail_page.dart';
import '../../models/dermatologist.dart';
import '../../models/diagnosis.dart';
import '../../models/slot.dart';
import '../../repositories/slot_repository.dart';
import '../../repositories/user_repository.dart';
import '../common/common.dart';

class BookSlotPage extends StatefulWidget {
  final Dermatologist? dermatologist;
  final Diagnosis? diagnosis;

  BookSlotPage({this.dermatologist, this.diagnosis});

  @override
  _BookSlotPageState createState() => _BookSlotPageState();
}

class _BookSlotPageState extends State<BookSlotPage> {
  late final List<Slot> slots;

  bool isBookingSlot = false;

  @override
  void initState() {
    setState(() {
      slots = widget.dermatologist?.slots ?? [];
      slots.sort((a, b) => getDayNumber(a.dayOfWeek).compareTo(getDayNumber(b.dayOfWeek)));
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.dermatologist?.user.firstName} ${widget.dermatologist?.user.lastName} Slots'),
      ),
      body: ListView.separated(
        itemCount: slots.length,
        separatorBuilder: (BuildContext context, int index) => SizedBox(height: 0),
        itemBuilder: (BuildContext context, int index) {
          Slot slot = slots[index];
          return Column(
            children: [
              if (index == 0 || slots[index - 1].dayOfWeek != slot.dayOfWeek)
                ListTile(
                  title: Text(
                    slot.dayOfWeek,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.blueAccent,
                    ),
                  ),
                  subtitle: Divider(),
                ),
              ListTile(
                title: Text(
                  'Slot ${index + 1}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 4),
                    Text(
                      'Time: ${DateFormat('MMM d, yyyy h:mm').format(calculateNextSlotDate(slot))}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                trailing: slot.scheduled
                    ? Icon(Icons.block, color: Colors.red, size: 24)
                    : Icon(Icons.check, color: Colors.green, size: 24),
                onTap: () {
                  if (!slot.scheduled) {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return StatefulBuilder(
                          builder: (BuildContext context, StateSetter setState) {
                            return AlertDialog(
                              title: Text('Book Slot'),
                              content: isBookingSlot
                                  ? Center(child: CircularProgressIndicator())
                                  : Text('Do you want to book this slot?'),
                              actions: [
                                TextButton(
                                  child: Text('Cancel'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                                TextButton(
                                  child: Text('Book'),
                                  onPressed: () async {
                                    if (!isBookingSlot) {
                                      setState(() {
                                        isBookingSlot = true;
                                      });
                                      final ap = await bookSlot(slot, widget.diagnosis, context);
                                      setState(() {
                                        isBookingSlot = false;
                                      });
                                      Navigator.of(context).pop();
                                      if (ap != null) {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                AppointmentDetailPage(
                                                  appointment: ap,
                                                ),
                                          ),
                                        );
                                      }
                                    }
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Slot is already booked.'),
                      ),
                    );
                  }
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Future<Appointment?> bookSlot(Slot slot, Diagnosis? diagnosis, BuildContext context) async {
    final repository = context.read<AppointmentRepository>();
    final patient = context.read<UserRepository>().patient;
    var appointment = Appointment(
        dermatologist: widget.dermatologist!,
        diagnosis: diagnosis,
        slot: slot,
        appoTime: calculateNextSlotDate(slot),
        patient: patient!
    );
    try {
      appointment = await repository.bookAppointment(appointment);
      return appointment;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Slot booking failed.'),
        ),
      );
    }
  }

  DateTime calculateNextSlotDate(Slot slot) {
    var now = DateTime.now();
    var nextSlotDate = DateTime.now().copyWith(hour: slot.startTime.hour, minute: slot.startTime.minute);
    final dayDiff = getDayNumber(slot.dayOfWeek) - now.weekday;
    if (dayDiff < 0) {
      nextSlotDate = nextSlotDate.add(Duration(days: 7 + dayDiff));
    } else {
      nextSlotDate = nextSlotDate.add(Duration(days: dayDiff));
    }
    return nextSlotDate;
  }

  int getDayNumber(String day) {
    switch (day) {
      case 'Monday':
        return 1;
      case 'Tuesday':
        return 2;
      case 'Wednesday':
        return 3;
      case 'Thursday':
        return 4;
      case 'Friday':
        return 5;
      case 'Saturday':
        return 6;
      case 'Sunday':
        return 7;
      default:
        return 0;
    }
  }
}
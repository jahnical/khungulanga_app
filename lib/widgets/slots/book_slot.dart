import 'dart:developer';

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
  List<Slot> slots = [];
  bool isLoading = true;
  bool isBookingSlot = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchSlots();
  }

  Future<void> fetchSlots() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      slots = await RepositoryProvider.of<SlotRepository>(context).getSlotsOf(widget.dermatologist!.id);
      slots.sort((a, b) => getDayNumber(a.dayOfWeek).compareTo(getDayNumber(b.dayOfWeek)));
      log(slots.toString());
    } catch (error) {
      log(error.toString());
      setState(() {
        errorMessage = 'Failed to fetch slots. Please retry.';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.dermatologist?.user.firstName} ${widget.dermatologist?.user.lastName} Slots'),
        actions: [
          IconButton(onPressed: fetchSlots, icon: Icon(Icons.refresh)),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: fetchSlots,
        child:  isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage != null
          ? Center(
            child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
            Text(
              errorMessage!,
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: fetchSlots,
              child: Text('Retry'),
            ),
        ],
      ),
          )
          : ListView.separated(
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
}

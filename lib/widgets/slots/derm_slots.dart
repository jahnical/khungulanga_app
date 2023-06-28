import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:khungulanga_app/models/slot.dart';
import 'package:khungulanga_app/repositories/slot_repository.dart';
import 'package:khungulanga_app/widgets/slots/slot_detail_page.dart';
import '../../repositories/user_repository.dart';
import '../common/common.dart';
import '../refreshable_widget.dart';

class DermatologistSlotsPage extends RefreshableWidget {
  @override
  _DermatologistSlotsPageState createState() => _DermatologistSlotsPageState();
}

class _DermatologistSlotsPageState extends RefreshableWidgetState<DermatologistSlotsPage> {
  List<Slot> slots = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchSlots();
  }

  Future<void> fetchSlots() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      // Fetch slots from the repository or any other data source
      slots = await RepositoryProvider.of<SlotRepository>(context).getSlotsOf(RepositoryProvider.of<UserRepository>(context).dermatologist!.id);
      slots.sort((a, b) => getDayNumber(a.dayOfWeek).compareTo(getDayNumber(b.dayOfWeek)));// Replace with actual repository method
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to fetch slots. Please try again.';
      });
      log(e.toString());
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(onRefresh: () { return fetchSlots(); },
        child: buildBody()
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => SlotDetailPage(callback: fetchSlots),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget buildBody() {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    } else if (errorMessage.isNotEmpty) {
      return buildErrorState();
    } else {
      // Group slots by day of the week
      final slotsByDay = groupSlotsByDay(slots);

      return ListView.builder(
        itemCount: slotsByDay.length,
        itemBuilder: (BuildContext context, int index) {
          final day = slotsByDay.keys.elementAt(index);
          final slotsForDay = slotsByDay[day]!;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  day,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18.0,
                  ),
                ),
              ),
              ListView.separated(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: slotsForDay.length,
                separatorBuilder: (BuildContext context, int index) => Divider(),
                itemBuilder: (BuildContext context, int index) {
                  Slot slot = slotsForDay[index];
                  return ListTile(
                    title: Text(
                      'Slot ${index + 1}: ${formatTime(slot.startTime)}',
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text(
                      '${slot.scheduled ? 'Booked' : 'Available'} on ${DateFormat('MMM d, yyyy h:mm').format(calculateNextSlotDate(slot))}',
                      style: TextStyle(
                        color: slot.scheduled ? Colors.red : Colors.green,
                      ),
                    ),
                    trailing: !slot.scheduled ? IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        showConfirmationDialog(slot);
                      },
                    ) : null,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => SlotDetailPage(slot: slot, callback: fetchSlots),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          );
        },
      );
    }
  }

  Widget buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            errorMessage,
            style: TextStyle(
              color: Colors.red,
              fontSize: 16,
            ),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: fetchSlots,
            child: Text('Retry'),
          ),
        ],
      ),
    );
  }

  Future<void> showConfirmationDialog(Slot slot) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmation'),
          content: Text('Are you sure you want to delete this slot?'),
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
                await deleteSlot(slot);
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.red,
              ),
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Future<void> deleteSlot(Slot slot) async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      // Delete the slot through the repository or any other data source
      await RepositoryProvider.of<SlotRepository>(context).deleteSlot(slot.id!); // Replace with actual repository method
      slots.remove(slot);
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to delete the slot. Please try again.';
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  Map<String, List<Slot>> groupSlotsByDay(List<Slot> slots) {
    final slotsByDay = <String, List<Slot>>{};

    for (final slot in slots) {
      final dayOfWeek = slot.dayOfWeek;
      if (!slotsByDay.containsKey(dayOfWeek)) {
        slotsByDay[dayOfWeek] = [];
      }
      slotsByDay[dayOfWeek]!.add(slot);
    }

    return slotsByDay;
  }

  String getDayOfWeek(int weekday) {
    switch (weekday) {
      case 1:
        return 'Monday';
      case 2:
        return 'Tuesday';
      case 3:
        return 'Wednesday';
      case 4:
        return 'Thursday';
      case 5:
        return 'Friday';
      case 6:
        return 'Saturday';
      case 7:
        return 'Sunday';
      default:
        return '';
    }
  }

  String formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')} ${time.hour < 12 ? 'AM' : 'PM'}';
  }

  @override
  refresh() {
    fetchSlots();
  }
}

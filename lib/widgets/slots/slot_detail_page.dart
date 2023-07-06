import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:khungulanga_app/repositories/user_repository.dart';
import 'package:khungulanga_app/widgets/common/common.dart';
import 'package:khungulanga_app/models/slot.dart';
import 'package:khungulanga_app/repositories/slot_repository.dart';

/// A page for creating or editing a slot.
class SlotDetailPage extends StatefulWidget {
  final Slot? slot;
  final Future<void> Function() callback;

  /// Constructs a SlotDetailPage.
  const SlotDetailPage({Key? key, this.slot, required this.callback}) : super(key: key);

  @override
  _SlotDetailPageState createState() => _SlotDetailPageState();
}

/// The state for the SlotDetailPage.
class _SlotDetailPageState extends State<SlotDetailPage> {
  final _formKey = GlobalKey<FormState>();
  late TimeOfDay _startTime;
  late int _dermatologistId;
  late bool _scheduled;
  late String _dayOfWeek;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.slot != null) {
      _startTime = TimeOfDay.fromDateTime(widget.slot!.startTime);
      _dermatologistId = widget.slot!.dermatologistId;
      _scheduled = widget.slot!.scheduled;
      _dayOfWeek = widget.slot!.dayOfWeek;
    } else {
      _startTime = TimeOfDay.now();
      _dermatologistId = RepositoryProvider.of<UserRepository>(context).dermatologist!.id;
      _scheduled = false;
      _dayOfWeek = 'Monday';
    }
  }

  /// Shows a time picker dialog.
  Future<void> _showTimePicker() async {
    final TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: _startTime,
    );

    if (selectedTime != null) {
      setState(() {
        _startTime = selectedTime;
      });
    }
  }

  /// Saves the slot.
  void _saveSlot() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final slotRepository = RepositoryProvider.of<SlotRepository>(context);

      final newSlot = Slot(
        startTime: DateTime(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day,
          _startTime.hour,
          _startTime.minute,
        ),
        dermatologistId: _dermatologistId,
        scheduled: _scheduled,
        dayOfWeek: _dayOfWeek,
        id: widget.slot?.id,
      );

      try {
        if (widget.slot != null) {
          await slotRepository.updateSlot(newSlot);
        } else {
          await slotRepository.saveSlot(newSlot);
        }

        Navigator.pop(context); // Close the page

        // Show success feedback
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(widget.slot != null ? 'Slot updated' : 'Slot created'),
          backgroundColor: Colors.green,
        ));
        widget.callback();
      } catch (error) {
        // Show error feedback
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error: $error'),
          backgroundColor: Colors.red,
        ));
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.slot != null ? 'Edit Slot' : 'Create Slot'),
      ),
      body: _isLoading
          ? Center(
        child: CircularProgressIndicator(),
      )
          : Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24.0, 48.0, 24.0, 0.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Start Time:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                ),
              ),
              InkWell(
                onTap: _showTimePicker,
                child: InputDecorator(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 10.0,
                      vertical: 12.0,
                    ),
                  ),
                  child: Text(
                    _startTime.format(context),
                    style: TextStyle(fontSize: 16.0),
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              /*Text(
                'Dermatologist ID:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                ),
              ),
              TextFormField(
                initialValue: _dermatologistId.toString(),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the dermatologist ID';
                  }
                  // Additional validation if needed
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    _dermatologistId = int.tryParse(value) ?? 0;
                  });
                },
              ),
              SizedBox(height: 16.0),*/
              /*Text(
                'Scheduled:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                ),
              ),
              Checkbox(
                value: _scheduled,
                onChanged: (value) {
                  setState(() {
                    _scheduled = value ?? false;
                  });
                },
              ),
              SizedBox(height: 16.0),*/
              Text(
                'Day of Week:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                ),
              ),
              DropdownButtonFormField<String>(
                value: _dayOfWeek,
                items: [
                  'Monday',
                  'Tuesday',
                  'Wednesday',
                  'Thursday',
                  'Friday',
                  'Saturday',
                  'Sunday',
                ].map((day) {
                  return DropdownMenuItem<String>(
                    value: day,
                    child: Text(day),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _dayOfWeek = value!;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select the day of week';
                  }
                  // Additional validation if needed
                  return null;
                },
              ),
              SizedBox(height: 32.0),
              ElevatedButton(
                onPressed: _saveSlot,
                child: Text(widget.slot != null ? 'Save Changes' : 'Create Slot'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

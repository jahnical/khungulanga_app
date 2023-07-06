import 'package:khungulanga_app/widgets/common/common.dart';

import 'dermatologist.dart';

/// Model class for managing slots.
class Slot {
  final int? id;
  DateTime startTime;
  int dermatologistId;
  bool scheduled;
  String dayOfWeek;

  /// Constructs a new instance of the Slot class.
  /// [startTime] is the start time of the slot.
  /// [dermatologistId] is the ID of the dermatologist.
  /// [scheduled] is whether the slot is scheduled or not.
  /// [dayOfWeek] is the day of the week of the slot.
  /// [id] is the ID of the slot.
  Slot({
    required this.startTime,
    required this.dermatologistId,
    this.scheduled = false,
    required this.dayOfWeek,
    this.id,
  });

  /// Constructs a Slot object from a JSON map.
  /// [json] is the JSON map representing the Slot.
  /// Returns a Slot object.
  factory Slot.fromJson(Map<String, dynamic> json) {
    return Slot(
      startTime: DateTime.now().copyWith(
        hour: int.parse(json['start_time'].split(":")[0]),
        minute: int.parse(json['start_time'].split(":")[1])
      ),
      dermatologistId: json['dermatologist_id'],
      scheduled: json['scheduled'],
      dayOfWeek: json['day_of_week'],
      id: json['id'],
    );
  }

  /// Converts the Slot object to a JSON map.
  /// Returns a JSON map representing the Slot.
  Map<String, dynamic> toJson() {
    return {
      'start_time': formatStartTime(startTime),
      'dermatologist_id': dermatologistId,
      'scheduled': scheduled,
      'day_of_week': dayOfWeek,
      'id': id,
    };
  }
}
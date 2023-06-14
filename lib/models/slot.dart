import 'package:khungulanga_app/widgets/common/common.dart';

import 'dermatologist.dart';

class Slot {
  final int? id;
  DateTime startTime;
  int dermatologistId;
  bool scheduled;
  String dayOfWeek;

  Slot({
    required this.startTime,
    required this.dermatologistId,
    this.scheduled = false,
    required this.dayOfWeek,
    this.id,
  });

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
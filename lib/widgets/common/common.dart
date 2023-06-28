import '../../models/slot.dart';

export './loading_indicator.dart';

String formatStartTime(DateTime startTime) {
  String hour = startTime.hour.toString().padLeft(2, '0');
  String minute = startTime.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
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
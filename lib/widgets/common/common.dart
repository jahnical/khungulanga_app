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
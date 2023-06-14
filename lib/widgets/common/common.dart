export './loading_indicator.dart';

String formatStartTime(DateTime startTime) {
  String hour = startTime.hour.toString().padLeft(2, '0');
  String minute = startTime.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}
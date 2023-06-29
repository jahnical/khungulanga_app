import 'appointment_chat.dart';
import 'diagnosis.dart';
import 'appointment.dart';
import 'user.dart';

// messages
class ChatMessage {
  final int? id;
  final User sender;
  final String text;
  final int chatId;
  final Diagnosis? diagnosis;
  final Appointment? appointment;
  final DateTime time;
  final bool seen;

  ChatMessage({
    this.id,
    required this.sender,
    required this.text,
    required this.chatId,
    this.diagnosis,
    this.appointment,
    required this.time,
    required this.seen,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      sender: User.fromJson(json['sender']),
      text: json['text'],
      chatId: json['chat_id'],
      diagnosis: json['diagnosis'] != null ? Diagnosis.fromJson(json['diagnosis']) : null,
      appointment: json['appointment'] != null ? Appointment.fromJson(json['appointment']) : null,
      time: DateTime.parse(json['time']),
      seen: json['seen'],
    );
  }

  Map<String, dynamic> toJsonMap() {
    return {
      'id': id,
      'sender_id': sender.id,
      'text': text,
      'chat_id': chatId,
      'diagnosis_id': diagnosis?.id,
      'appointment_id': appointment?.id,
      'time': time.toIso8601String(),
      'seen': seen,
    };
  }
}
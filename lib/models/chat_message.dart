import 'appointment_chat.dart';
import 'diagnosis.dart';
import 'appointment.dart';
import 'user.dart';

/// Deprecated
/// Model class for managing chat messages.
class ChatMessage {
  final int? id;
  final User sender;
  final String text;
  final int chatId;
  final Diagnosis? diagnosis;
  final Appointment? appointment;
  final DateTime time;
  final bool seen;

  /// Constructs a new instance of the ChatMessage class.
  /// [id] is the ID of the chat message.
  /// [sender] is the sender of the chat message.
  /// [text] is the text of the chat message.
  /// [chatId] is the ID of the chat.
  /// [diagnosis] is the diagnosis of the chat message.
  /// [appointment] is the appointment of the chat message.
  /// [time] is the time of the chat message.
  /// [seen] is whether the chat message is seen or not.
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

  /// Converts the ChatMessage object to a JSON map.
  /// Returns a JSON map representing the ChatMessage.
  /// [json] is the JSON map representing the ChatMessage.
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

  /// Converts the ChatMessage object to a JSON map.
  /// Returns a JSON map representing the ChatMessage.
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
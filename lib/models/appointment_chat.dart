import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'appointment.dart';
import 'chat_message.dart';
import 'dermatologist.dart';
import 'diagnosis.dart';
import 'patient.dart';

/// Deprecated
/// Model class for managing appointment chats.
class AppointmentChat {
  final int? id;
  final Patient patient;
  final Diagnosis? diagnosis;
  final Dermatologist dermatologist;
  Appointment appointment;
  List<ChatMessage> messages = [];

  /// Constructs a new instance of the AppointmentChat class.
  /// [id] is the ID of the appointment chat.
  /// [patient] is the patient of the appointment chat.
  /// [diagnosis] is the diagnosis of the appointment chat.
  /// [dermatologist] is the dermatologist of the appointment chat.
  /// [appointment] is the appointment of the appointment chat.
  /// [messages] is the list of messages of the appointment chat.
  AppointmentChat({
    this.id,
    required this.patient,
    required this.diagnosis,
    required this.dermatologist,
    required this.appointment,
    required this.messages
  });

  /// Converts the AppointmentChat object to a JSON map.
  /// Returns a JSON map representing the AppointmentChat.
  /// [json] is the JSON map representing the AppointmentChat.
  factory AppointmentChat.fromJson(Map<String, dynamic> json) {
    return AppointmentChat(
      id: json['id'],
      patient: Patient.fromJson(json['patient']),
      diagnosis: json['diagnosis'] == null? null : Diagnosis.fromJson(json['diagnosis']),
      dermatologist: Dermatologist.fromJson(json['dermatologist']),
      appointment: Appointment.fromJson(json['appointment']),
      messages: json['messages'] == null? [] : json['messages'].map((e) => ChatMessage.fromJson(e)).toList().cast<ChatMessage>()
    );
  }

  /// Converts the AppointmentChat object to a JSON map.
  /// Returns a JSON map representing the AppointmentChat.
  Map<String, dynamic> toJsonMap() {
    return {
      'id': id,
      'patient_id': patient.id,
      'diagnosis_id': diagnosis?.id,
      'dermatologist_id': dermatologist.id,
      //'appointment_id': appointment.id,
      //'messages': []//messages.map((message) => message.toJsonMap()).toList(),
    };
  }
}
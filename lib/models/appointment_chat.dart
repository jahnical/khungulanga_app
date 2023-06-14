import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'appointment.dart';
import 'chat_message.dart';
import 'dermatologist.dart';
import 'diagnosis.dart';
import 'patient.dart';

class AppointmentChat {
  final int? id;
  final Patient patient;
  final Diagnosis? diagnosis;
  final Dermatologist dermatologist;
  Appointment appointment;
  List<ChatMessage> messages = [];

  AppointmentChat({
    this.id,
    required this.patient,
    required this.diagnosis,
    required this.dermatologist,
    required this.appointment,
    required this.messages
  });

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
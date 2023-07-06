import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:khungulanga_app/models/slot.dart';

import 'dermatologist.dart';
import 'diagnosis.dart';
import 'patient.dart';

/// Model class for managing appointments.
class Appointment {
  final int? id;
  Dermatologist dermatologist;
  Patient? patient;
  DateTime? bookDate = DateTime.now();
  DateTime? appoTime;
  bool done;
  Duration? duration;
  double? cost;
  DateTime? patientRemoved;
  DateTime? dermatologistRemoved;
  DateTime? patientCancelled;
  DateTime? dermatologistCancelled;
  String extraInfo;
  Diagnosis? diagnosis;
  Slot? slot;

  /// Constructs a new instance of the Appointment class.
  /// [id] is the ID of the appointment.
  /// [dermatologist] is the dermatologist of the appointment.
  /// [patient] is the patient of the appointment.
  /// [bookDate] is the date the appointment was booked.
  /// [appoTime] is the date the appointment is scheduled for.
  /// [done] is whether the appointment is done or not.
  /// [duration] is the duration of the appointment.
  /// [cost] is the cost of the appointment.
  /// [patientRemoved] is the date the patient was removed from the appointment.
  /// [dermatologistRemoved] is the date the dermatologist was removed from the appointment.
  /// [patientCancelled] is the date the patient cancelled the appointment.
  /// [dermatologistCancelled] is the date the dermatologist cancelled the appointment.
  /// [extraInfo] is the extra information of the appointment.
  /// [diagnosis] is the diagnosis of the appointment.
  /// [slot] is the slot of the appointment.
  /// Returns a new instance of the Appointment class.
  Appointment({
    this.id,
    required this.dermatologist,
    this.patient,
    this.bookDate,
    this.appoTime,
    this.done = false,
    this.duration = const Duration(hours: 1),
    this.cost = 0.0,
    this.patientRemoved,
    this.dermatologistRemoved,
    this.patientCancelled,
    this.dermatologistCancelled,
    this.diagnosis,
    this.extraInfo = "Extra Info",
    this.slot
  });

  /// Creates an Appointment from json.
  /// [json] is the JSON map to convert.
  /// Returns a Appointment.
  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'],
      dermatologist: Dermatologist.fromJson(json['dermatologist']),
      patient: json['patient'] != null ? Patient.fromJson(json['patient']) : null,
      bookDate: json['book_date'] != null ? DateTime.parse(json['book_date']) : null,
      appoTime: json['appo_date'] != null ? DateTime.parse(json['appo_date']) : null,
      done: json['done'] ?? false,
      duration: json['duration'] != null ? Duration(minutes: json['duration'] ?? 0) : null,
      cost: json['cost']?.toDouble() ?? 0.0,
      patientRemoved: json['patient_removed'] != null ? DateTime.parse(json['patient_removed']) : null,
      dermatologistRemoved: json['dermatologist_removed'] != null ? DateTime.parse(json['dermatologist_removed']) : null,
      patientCancelled: json['patient_cancelled'] != null ? DateTime.parse(json['patient_cancelled']) : null,
      dermatologistCancelled: json['dermatologist_cancelled'] != null ? DateTime.parse(json['dermatologist_cancelled']) : null,
      extraInfo: json['extra_info'] ?? "",
      diagnosis: json['diagnosis'] != null ? Diagnosis.fromJson(json['diagnosis']) : null,
      slot: json['slot'] != null ? Slot.fromJson(json['slot']) : null,
    );
  }

  /// Converts an Appointment to json.
  /// Returns a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dermatologist_id': dermatologist.id,
      'patient_id': patient?.id,
      'book_date': bookDate?.toIso8601String(),
      'appo_date': appoTime?.toIso8601String(),
      'done': done,
      'duration': duration?.inMinutes,
      'cost': cost,
      'extra_info': extraInfo,
      'patient_removed': patientRemoved?.toIso8601String(),
      'dermatologist_removed': dermatologistRemoved?.toIso8601String(),
      'patient_cancelled': patientCancelled?.toIso8601String(),
      'dermatologist_cancelled': dermatologistCancelled?.toIso8601String(),
      'diagnosis_id': diagnosis?.id,
      'slot_id': slot?.id,
    };
  }

  /// Returns the Appointment with copied values.
  Appointment copyWith({
    int? id,
    Dermatologist? dermatologist,
    Patient? patient,
    DateTime? bookDate,
    DateTime? appoDate,
    bool? done,
    Duration? duration,
    double? cost,
    DateTime? patientApproved,
    DateTime? dermatologistApproved,
    DateTime? patientRejected,
    DateTime? dermatologistRejected,
    String? extraInfo,
    Diagnosis? diagnosis,
    Slot? slot,
  }) {
    return Appointment(
      id: id ?? this.id,
      dermatologist: dermatologist ?? this.dermatologist,
      patient: patient ?? this.patient,
      bookDate: bookDate ?? this.bookDate,
      appoTime: appoDate ?? this.appoTime,
      done: done ?? this.done,
      duration: duration ?? this.duration,
      cost: cost ?? this.cost,
      patientRemoved: patientApproved ?? this.patientRemoved,
      dermatologistRemoved: dermatologistApproved ?? this.dermatologistRemoved,
      patientCancelled: patientRejected ?? this.patientCancelled,
      dermatologistCancelled: dermatologistRejected ?? this.dermatologistCancelled,
      extraInfo: extraInfo ?? this.extraInfo,
      diagnosis: diagnosis ?? this.diagnosis,
      slot: slot ?? this.slot,
    );
  }
}

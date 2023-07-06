
import 'package:khungulanga_app/models/patient.dart';

import 'dermatologist.dart';
import 'prediction.dart';

/// Model class for managing diagnoses.
class Diagnosis {
  final String imageUrl;
  final String bodyPart;
  final bool itchy;
  final DateTime date;
  final List<Prediction> predictions;
  final int id;
  bool approved;
  String action;
  final Patient patient;
  Dermatologist? dermatologist;
  String? extraDermInfo;

  /// Constructs a new instance of the Diagnosis class.
  /// [id] is the ID of the diagnosis.
  /// [imageUrl] is the image URL of the diagnosis.
  /// [bodyPart] is the body part of the diagnosis.
  /// [itchy] is whether the diagnosis is itchy or not.
  /// [date] is the date of the diagnosis.
  /// [predictions] is the predictions of the diagnosis.
  /// [patient] is the patient of the diagnosis.
  /// [approved] is whether the diagnosis is approved or not.
  /// [action] is the action of the diagnosis.
  /// [dermatologist] is the dermatologist of the diagnosis.
  /// [extraDermInfo] is the extra dermatologist information of the diagnosis.
  Diagnosis(this.id, {
    required this.imageUrl,
    required this.bodyPart,
    required this.itchy,
    required this.date,
    required this.predictions,
    required this.patient,
    required this.approved,
    required this.action,
    this.dermatologist,
    this.extraDermInfo,
  });

  /// Converts the Diagnosis object to a JSON map.
  /// Returns a JSON map representing the Diagnosis.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'image': imageUrl,
      'body_part': bodyPart,
      'itchy': itchy,
      'date': date.toIso8601String(),
      //'predictions': predictions.map((prediction) => prediction.toJson()).toList(),
      'patient_id': patient.id,
      'dermatologist_id': dermatologist?.id,
      'approved': approved,
      'action': action,
      'extra_derm_info': extraDermInfo,
    };
  }

  /// Constructs a Diagnosis object from a JSON map.
  /// [json] is the JSON map representing the Diagnosis.
  /// Returns a Diagnosis object.
  factory Diagnosis.fromJson(Map<String, dynamic> json) {
    return Diagnosis(
      json['id'],
      imageUrl: json['image'],
      bodyPart: json['body_part'],
      itchy: json['itchy'],
      date: DateTime.parse(json['date']),
      predictions: (json['predictions'] as List<dynamic>)
          .map((predictionJson) => Prediction.fromJson(predictionJson))
          .toList(),
      patient: Patient.fromJson(json['patient']),
      dermatologist: json['dermatologist'] != null
          ? Dermatologist.fromJson(json['dermatologist'])
          : null,
      approved: json['approved'],
      action: json['action'],
      extraDermInfo: json['extra_derm_info'],
    );
  }
}

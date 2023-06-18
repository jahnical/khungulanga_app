
import 'package:khungulanga_app/models/patient.dart';

import 'dermatologist.dart';
import 'prediction.dart';

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

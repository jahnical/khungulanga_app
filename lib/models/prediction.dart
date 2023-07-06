import 'package:flutter/material.dart';
import 'disease.dart';

/// Model class for managing predictions.
class Prediction {
  final int? id;
  final Disease disease;
  final double probability;
  bool approved;
  String? treatment;
  int? treatmentId;

  /// Constructs a new instance of the Prediction class.
  /// [disease] is the disease predicted.
  /// [probability] is the probability of the prediction.
  /// [approved] is whether the prediction is approved or not.
  /// [treatment] is the treatment for the prediction.
  /// [id] is the ID of the prediction.
  /// [treatmentId] is the ID of the treatment.
  Prediction({
    required this.disease,
    required this.probability,
    required this.approved,
    this.treatment,
    this.id,
    this.treatmentId,
  });

  /// Constructs a Prediction object from a JSON map.
  /// [json] is the JSON map representing the Prediction.
  /// Returns a Prediction object.
  factory Prediction.fromJson(Map<String, dynamic> json) {
    return Prediction(
      disease: Disease.fromJson(json['disease']),
      probability: json['probability'],
      approved: json['approved'],
      treatment: json['treatment'],
      id: json['id'],
      treatmentId: json['treatment_id'],
    );
  }

  /// Converts the Prediction object to a JSON map.
  /// Returns a JSON map representing the Prediction.
  Map<String, dynamic> toJson() {
    return {
      'disease_id': disease.id,
      'probability': probability,
      'approved': approved,
      'treatment': treatment,
      'id': id,
      'treatment_id': treatmentId,
    };
  }
}
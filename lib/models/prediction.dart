import 'package:flutter/material.dart';
import 'disease.dart';

class Prediction {
  final Disease disease;
  final double probability;
  final bool approved;
  final String? treatment;

  Prediction({
    required this.disease,
    required this.probability,
    required this.approved,
    this.treatment,
  });

  factory Prediction.fromJson(Map<String, dynamic> json) {
    return Prediction(
      disease: Disease.fromJson(json['disease']),
      probability: json['probability'],
      approved: json['approved'],
      treatment: json['treatment'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'disease': disease.toJson(),
      'probability': probability,
      'approved': approved,
      'treatment': treatment,
    };
  }
}
import 'package:flutter/material.dart';
import 'disease.dart';

class Prediction {
  final int? id;
  final Disease disease;
  final double probability;
  bool approved;
  String? treatment;

  Prediction({
    required this.disease,
    required this.probability,
    required this.approved,
    this.treatment,
    this.id,
  });

  factory Prediction.fromJson(Map<String, dynamic> json) {
    return Prediction(
      disease: Disease.fromJson(json['disease']),
      probability: json['probability'],
      approved: json['approved'],
      treatment: json['treatment'],
      id: json['id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'disease_id': disease.id,
      'probability': probability,
      'approved': approved,
      'treatment': treatment,
      'id': id,
    };
  }
}
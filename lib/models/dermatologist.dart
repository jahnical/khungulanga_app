import 'dart:developer';

import 'package:khungulanga_app/models/slot.dart';

import 'clinic.dart';
import 'user.dart';

class Dermatologist {
  int id;
  String qualification;
  String email;
  String phoneNumber;
  Clinic clinic;
  String specialization;
  User user;
  double hourlyRate;
  List<Slot> slots;

  Dermatologist({
    required this.id,
    required this.qualification,
    required this.email,
    required this.phoneNumber,
    required this.clinic,
    required this.user,
    required this.specialization,
    required this.hourlyRate,
    required this.slots
  });

  factory Dermatologist.fromJson(Map<String, dynamic> json) {
    log(json.toString());
    return Dermatologist(
      id: json['id'],
      qualification: json['qualification'],
      email: json['email'],
      phoneNumber: json['phone_number'],
      clinic: Clinic.fromJson(json['clinic']),
      user: User.fromJson(json['user']),
      specialization: json['specialization'],
      hourlyRate: json['hourly_rate'],
      slots: json['slots'] == null? [] : json['slots'].map((e) => Slot.fromJson(e)).toList().cast<Slot>()
    );
  }

  static List<Map<String, String>> specializations = [
    {
      "id": "COSMETIC",
      "name": "Cosmetic Dermatologist"
    },
    {
      "id": "DERMATOPATHOLOGIST",
      "name": "Dermatopathologist"
    },
    {
      "id": "DERMATOSURGEON",
      "name": "Dermatosurgeon"
    },
    {
      "id": "IMMUNODERMATOLOGIST",
      "name": "Immunodermatologist"
    },
    {
      "id": "MOHS_SURGEON",
      "name": "Mohs Surgeon"
    },
    {
      "id": "PAEDIATRIC",
      "name": "Paediatric Dermatologist"
    },
    {
      "id": "TELEDERMATOLOGIST",
      "name": "Teledermatologist"
    },
  ];
}
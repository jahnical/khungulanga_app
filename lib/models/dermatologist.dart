import 'dart:developer';

import 'package:khungulanga_app/models/slot.dart';

import 'clinic.dart';
import 'user.dart';

/// Model class for managing dermatologists.
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

  /// Constructs a new instance of the Dermatologist class.
  /// [id] is the ID of the dermatologist.
  /// [qualification] is the qualification of the dermatologist.
  /// [email] is the email of the dermatologist.
  /// [phoneNumber] is the phone number of the dermatologist.
  /// [clinic] is the clinic of the dermatologist.
  /// [user] is the user of the dermatologist.
  /// [specialization] is the specialization of the dermatologist.
  /// [hourlyRate] is the hourly rate of the dermatologist.
  /// [slots] is the list of slots of the dermatologist.
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

  /// Constructs a Dermatologist object from a JSON map.
  /// [json] is the JSON map representing the Dermatologist.
  /// Returns a Dermatologist object.
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

  /// Converts the Dermatologist object to a JSON map.
  /// Returns a JSON map representing the Dermatologist.
  Map<String, dynamic> toJson() => {
        'id': id,
        'qualification': qualification,
        'email': email,
        'phone_number': phoneNumber,
        'clinic_id': clinic.id,
        'user_id': user.id,
        'specialization': specialization,
        'hourly_rate': hourlyRate,
      };

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
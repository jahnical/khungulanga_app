import 'package:khungulanga_app/models/user.dart';

/// Model class for managing patients.
class Patient {
  final int id;
  final String? username;
  final String? password;
  final String? firstName;
  final String? lastName;
  final String ?email;
  DateTime dob;
  String gender;
  bool? isStaff =false;
  bool? isActive = false;
  DateTime? lastLogin;
  DateTime? dateJoined;
  User? user;

  /// Constructs a new instance of the Patient class.
  /// [id] is the ID of the patient.
  /// [username] is the username of the patient.
  /// [password] is the password of the patient.
  /// [firstName] is the first name of the patient.
  /// [lastName] is the last name of the patient.
  /// [email] is the email of the patient.
  /// [dob] is the date of birth of the patient.
  /// [gender] is the gender of the patient.
  /// [isStaff] is whether the patient is staff or not.
  /// [isActive] is whether the patient is active or not.
  /// [lastLogin] is the last login of the patient.
  /// [dateJoined] is the date joined of the patient.
  /// [user] is the user of the patient.
  Patient({
    required this.id,
    this.username,
    this.password,
    this.firstName,
    this.lastName,
    this.email,
    required this.dob,
    required this.gender,
    this.isStaff,
    this.isActive,
    this.lastLogin,
    this.dateJoined,
    this.user
  });

  /// Constructs a Patient object from a JSON map.
  /// [json] is the JSON map representing the Patient.
  /// Returns a Patient object.
  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      id: json['id'],
      dob: DateTime.parse(json['dob']),
      gender: json['gender'],
      user: User.fromJson(json['user']),
    );
  }

  /// Converts the Patient object to a JSON map.
  /// Returns a JSON map representing the Patient.
  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'password': password,
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'is_staff': isStaff,
        'is_active': isActive,
        'last_login': lastLogin?.toIso8601String(),
        'date_joined': dateJoined?.toIso8601String(),
        'dob': dob.toIso8601String(),
        'gender': gender,
      };
}

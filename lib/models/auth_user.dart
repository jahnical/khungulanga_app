import 'package:intl/intl.dart';

import 'clinic.dart';

class AuthUser {
  int id;
  String username;
  String token;

  AuthUser({required this.id,
      required this.username,
      required this.token});

  factory AuthUser.fromDatabaseJson(Map<String, dynamic> data) => AuthUser(
      id: data['id'],
      username: data['username'],
      token: data['token'],
  );

  Map<String, dynamic> toDatabaseJson() => {
        "id": id,
        "username": username,
        "token": token
      };
}

class UserLogin {
  String username;
  String password;

  UserLogin({required this.username, required this.password});

  Map <String, dynamic> toDatabaseJson() => {
    "username": username,
    "password": password
  };
}

class Token{
  String token;

  Token({required this.token});

  factory Token.fromJson(Map<String, dynamic> json) {
    return Token(
      token: json['token']
    );
  }
}

class UserRegister {
  String username;
  String password;
  String email;
  String firstName;
  String lastName;
  DateTime dob;
  String gender;

  UserRegister({
    required this.username,
    required this.password,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.dob,
    required this.gender,
  });

  Map<String, dynamic> toDatabaseJson() => {
        "username": username,
        "password": password,
        "email": email,
        "first_name": firstName,
        "last_name": lastName,
        "dob": dob.toIso8601String(),
        "gender": gender,
      };
}

class DermUserRegister {
  String username;
  String password;
  String email;
  String firstName;
  String lastName;
  final String phoneNumber;
  final String qualification;
  final Clinic clinic;
  String specialization;
  double hourlyRate;


  DermUserRegister({
    required this.username,
    required this.password,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.qualification,
    required this.phoneNumber,
    required this.clinic,
    required this.specialization,
    required this.hourlyRate,
  });

  Map<String, dynamic> toDatabaseJson() => {
    "username": username,
    "password": password,
    "email": email,
    "first_name": firstName,
    "last_name": lastName,
    "qualification": qualification,
    "phone_number": phoneNumber,
    "clinic": clinic.toJson(),
    "specialization": specialization,
    'hourly_rate': hourlyRate
  };
}

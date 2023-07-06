import 'package:intl/intl.dart';

import 'clinic.dart';

/// Model class for managing users.
class AuthUser {
  int id;
  String username;
  String token;

  /// Constructs a new instance of the AuthUser class.
  /// [id] is the ID of the user.
  /// [username] is the username of the user.
  /// [token] is the token of the user.
  AuthUser({required this.id,
      required this.username,
      required this.token});

  /// Constructs a AuthUser object from a JSON map.
  /// [json] is the JSON map representing the AuthUser.
  factory AuthUser.fromDatabaseJson(Map<String, dynamic> data) => AuthUser(
      id: data['id'],
      username: data['username'],
      token: data['token'],
  );

  /// Converts the AuthUser object to a JSON map.
  Map<String, dynamic> toDatabaseJson() => {
        "id": id,
        "username": username,
        "token": token
      };
}

/// Model class for managing users.
class UserLogin {
  String username;
  String password;

  /// Constructs a new instance of the AuthUser class.
  /// [username] is the username of the user.
  /// [password] is the password of the user.
  UserLogin({required this.username, required this.password});

  /// Constructs a AuthUser object from a JSON map.
  Map <String, dynamic> toDatabaseJson() => {
    "username": username,
    "password": password
  };
}

/// Model class for user token.
class Token{
  String token;

  /// Constructs a new instance of the Token class.
  Token({required this.token});

  factory Token.fromJson(Map<String, dynamic> json) {
    return Token(
      token: json['token']
    );
  }
}

/// Model class for registering user.
class UserRegister {
  String username;
  String password;
  String email;
  String firstName;
  String lastName;
  DateTime dob;
  String gender;

  /// Constructs a new instance of the UserRegister class.
  /// [username] is the username of the user.
  /// [password] is the password of the user.
  /// [email] is the email of the user.
  /// [firstName] is the first name of the user.
  /// [lastName] is the last name of the user.
  /// [dob] is the date of birth of the user.
  /// [gender] is the gender of the user.
  UserRegister({
    required this.username,
    required this.password,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.dob,
    required this.gender,
  });

  /// Converts a Register user object to JSON.
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

/// Model class for registering doctor.
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

  /// Constructs a new instance of the DermUserRegister class.
  /// [username] is the username of the user.
  /// [password] is the password of the user.
  /// [email] is the email of the user.
  /// [firstName] is the first name of the user.
  /// [lastName] is the last name of the user.
  /// [qualification] is the qualification of the user.
  /// [phoneNumber] is the phone number of the user.
  /// [clinic] is the clinic of the user.
  /// [specialization] is the specialization of the user.
  /// [hourlyRate] is the hourly rate of the user.
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

  /// Converts a Register user object to JSON.
  /// Returns a JSON map representing the Register user.
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

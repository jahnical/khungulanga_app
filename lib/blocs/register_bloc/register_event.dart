part of 'register_bloc.dart';

/// Represents the base event for the registration process.
///
/// Subclasses of [RegisterEvent] represent different events that can occur during the registration process.
abstract class RegisterEvent extends Equatable {
  const RegisterEvent();

  @override
  List<Object> get props => [];
}

/// Represents the event when the register button is pressed for a regular user registration.
class RegisterButtonPressed extends RegisterEvent {
  final String firstName;
  final String lastName;
  final String username;
  final String email;
  final String password;
  final String confirmPassword;
  final DateTime dateOfBirth;
  final String gender;

  /// Constructs a [RegisterButtonPressed] event with the provided user registration data.
  const RegisterButtonPressed({
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.password,
    required this.confirmPassword,
    required this.email,
    required this.dateOfBirth,
    required this.gender,
  });

  @override
  List<Object> get props => [
    firstName,
    lastName,
    username,
    password,
    confirmPassword,
    dateOfBirth,
    gender,
    email,
  ];

  @override
  String toString() => 'RegisterButtonPressed { firstName: $firstName, lastName: $lastName, username: $username, password: $password, confirmPassword: $confirmPassword, dateOfBirth: $dateOfBirth, gender: $gender, email: $email }';
}

/// Represents the event when the register button is pressed for a dermatologist registration.
class RegisterButtonPressedDerm extends RegisterEvent {
  final String firstName;
  final String lastName;
  final String username;
  final String email;
  final String password;
  final String confirmPassword;
  final String phoneNumber;
  final String qualification;
  final Clinic clinic;
  final String specialization;
  final double hourlyRate;

  /// Constructs a [RegisterButtonPressedDerm] event with the provided dermatologist registration data.
  const RegisterButtonPressedDerm({
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.password,
    required this.confirmPassword,
    required this.email,
    required this.qualification,
    required this.phoneNumber,
    required this.clinic,
    required this.specialization,
    required this.hourlyRate
  });

  @override
  List<Object> get props => [
    firstName,
    lastName,
    username,
    password,
    confirmPassword,
    phoneNumber,
    qualification,
    email,
    clinic,
    specialization
  ];

  @override
  String toString() => 'RegisterButtonPressed { firstName: $firstName, lastName: $lastName, username: $username, password: $password, confirmPassword: $confirmPassword, email: $email }';
}

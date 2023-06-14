part of 'register_bloc.dart';

abstract class RegisterEvent extends Equatable {
  const RegisterEvent();

  @override
  List<Object> get props => [];
}

class RegisterButtonPressed extends RegisterEvent {
  final String firstName;
  final String lastName;
  final String username;
  final String email;
  final String password;
  final String confirmPassword;
  final DateTime dateOfBirth;
  final String gender;

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
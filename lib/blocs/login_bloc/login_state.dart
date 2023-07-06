part of 'login_bloc.dart';

/// The base class for all login states.
abstract class LoginState extends Equatable {
  const LoginState();

  @override
  List<Object> get props => [];
}

/// Represents the initial state of the login process.
class LoginInitial extends LoginState {}

/// Represents the state when the login process is in progress.
class LoginLoading extends LoginState {}

/// Represents the state when the login process encounters an error.
class LoginFaliure extends LoginState {
  final String error;

  /// Constructs a [LoginFaliure] with the given error message.
  const LoginFaliure({required this.error});

  @override
  List<Object> get props => [error];

  @override
  String toString() => ' LoginFaliure { error: $error }';
}
part of 'register_bloc.dart';

/// Represents the base state for the registration process.
///
/// Subclasses of [RegisterState] represent different states of the registration process.
abstract class RegisterState extends Equatable {
  const RegisterState();

  @override
  List<Object> get props => [];
}

/// Represents the initial state of the registration process.
class RegisterInitial extends RegisterState {}

/// Represents the state when the registration process is loading or in progress.
class RegisterLoading extends RegisterState {}

/// Represents the state when the registration process is successfully completed.
class RegisterSuccess extends RegisterState {}

/// Represents the state when the registration process has encountered a failure.
class RegisterFailure extends RegisterState {
  final String error;

  /// Constructs a [RegisterFailure] with the given error message.
  const RegisterFailure({required this.error});

  @override
  List<Object> get props => [error];

  @override
  String toString() => 'RegisterFailure { error: $error }';
}

part of 'auth_bloc.dart';

@immutable
/// The base class for all authentication states.
abstract class AuthState extends Equatable {
  @override
  List<Object> get props => [];
}

/// Represents the uninitialized authentication state.
class AuthUninitialized extends AuthState {}

/// Represents the authenticated state for a patient user.
class AuthAuthenticatedPatient extends AuthState {
  final AuthUser? authUser;

  AuthAuthenticatedPatient(this.authUser);
}

/// Represents the authenticated state for a dermatologist user.
class AuthAuthenticatedDermatologist extends AuthState {
  final AuthUser? authUser;

  AuthAuthenticatedDermatologist(this.authUser);
}

/// Represents the unauthenticated state.
class AuthUnauthenticated extends AuthState {}

/// Represents the loading state during authentication.
class AuthLoading extends AuthState {}

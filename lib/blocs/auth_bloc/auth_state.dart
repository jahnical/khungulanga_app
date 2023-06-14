part of 'auth_bloc.dart';

@immutable
abstract class AuthState extends Equatable {
  @override
  List<Object> get props => [];
}

class AuthUninitialized extends AuthState {}

class AuthAuthenticatedPatient extends AuthState {
  final AuthUser? authUser;
  AuthAuthenticatedPatient(this.authUser);
}

class AuthAuthenticatedDermatologist extends AuthState {
  final AuthUser? authUser;
  AuthAuthenticatedDermatologist(this.authUser);
}

class AuthUnauthenticated extends AuthState {}

class AuthLoading extends AuthState {}
part of 'auth_bloc.dart';

@immutable
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class AppStarted extends AuthEvent {
  BuildContext context;
  AppStarted(this.context);
}

class LoggedIn extends AuthEvent {
  final AuthUser user;

  const LoggedIn({required this.user});

  @override
  List<Object> get props => [user];

  @override
  String toString() => 'LoggedIn { user: $user.username.toString() }';
}

class LoggedOut extends AuthEvent {}
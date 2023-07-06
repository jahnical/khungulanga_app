part of 'auth_bloc.dart';

@immutable
/// The base class for all authentication events.
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

/// Represents the event when the app is started.
class AppStarted extends AuthEvent {
  final BuildContext context;

  AppStarted(this.context);

  @override
  List<Object> get props => [context];
}

/// Represents the event when a user is logged in.
class LoggedIn extends AuthEvent {
  final AuthUser user;

  const LoggedIn({required this.user});

  @override
  List<Object> get props => [user];

  @override
  String toString() => 'LoggedIn { user: ${user.username.toString()} }';
}

/// Represents the event when a user is logged out.
class LoggedOut extends AuthEvent {}

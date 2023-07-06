part of 'login_bloc.dart';

/// The base class for all login events.
abstract class LoginEvent extends Equatable {
  const LoginEvent();
}

/// Represents the event when the login button is pressed.
class LoginButtonPressed extends LoginEvent {
  final String username;
  final String password;

  /// Constructs a [LoginButtonPressed] event with the given [username] and [password].
  const LoginButtonPressed({
    required this.username,
    required this.password,
  });

  @override
  List<Object> get props => [username, password];

  @override
  String toString() => 'LoginButtonPressed { username: $username, password: $password }';
}

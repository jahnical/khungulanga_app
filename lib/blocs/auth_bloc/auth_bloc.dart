import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';
import 'package:khungulanga_app/models/auth_user.dart';
import 'package:khungulanga_app/repositories/user_repository.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../../repositories/notifications_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc
    extends Bloc<AuthEvent, AuthState> {
  final UserRepository userRepository;

  AuthBloc({required this.userRepository}) : super(AuthUninitialized());

  @override
  AuthState get initialState => AuthUninitialized();

  @override
  Stream<AuthState> mapEventToState(
    AuthEvent event,
  ) async* {
    if (event is AppStarted) {

      //For web testing
      if (kIsWeb) {
        yield AuthAuthenticatedPatient(null);
        return;
      }
      final user = await userRepository.getUserFromDB();
      final bool hasToken = await userRepository.hasToken();

      if (hasToken) {
        if (userRepository.patient != null) {
          yield AuthAuthenticatedPatient(user);
        } else if (userRepository.dermatologist != null) {
          yield AuthAuthenticatedDermatologist(user);
        }
        NotificationRepository().initialize();
      } else {
        yield AuthUnauthenticated();
      }
    }

    if (event is LoggedIn) {
      yield AuthLoading();

      await userRepository.persistToken(
        user: event.user
      );
      final user = await userRepository.getUserFromDB();
      if (userRepository.patient != null) {
        yield AuthAuthenticatedPatient(user);
      } else if (userRepository.dermatologist != null) {
        yield AuthAuthenticatedDermatologist(user);
      }
    }

    if (event is LoggedOut) {
      yield AuthLoading();

      await userRepository.deleteToken(id: 0);

      yield AuthUnauthenticated();
    }
  }
}
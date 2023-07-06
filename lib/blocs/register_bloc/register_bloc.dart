import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:khungulanga_app/repositories/user_repository.dart';

import '../../models/clinic.dart';
import '../auth_bloc/auth_bloc.dart';

part 'register_event.dart';
part 'register_state.dart';

/// A BLoC responsible for handling the registration process.
///
/// The [RegisterBloc] receives [RegisterEvent]s and emits [RegisterState]s in response to those events.
class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  final UserRepository userRepository;
  final AuthBloc authenticationBloc;
  final BuildContext context;

  /// Constructs a [RegisterBloc] with the necessary dependencies and sets the initial state to [RegisterInitial].
  RegisterBloc({
    required this.userRepository,
    required this.authenticationBloc,
    required this.context,
  }) : super(RegisterInitial());

  @override
  Stream<RegisterState> mapEventToState(
      RegisterEvent event,
      ) async* {
    if (event is RegisterButtonPressed) {
      yield RegisterLoading();

      try {
        // Call the user repository to register the user
        await userRepository.register(
          username: event.username,
          email: event.email,
          password: event.password,
          dob: event.dateOfBirth,
          firstName: event.firstName,
          lastName: event.lastName,
          gender: event.gender,
        );

        // Authenticate the registered user
        final user = await userRepository.authenticate(
          username: event.username,
          password: event.password,
        );

        // Emit the success state and trigger the authentication bloc's LoggedIn event
        authenticationBloc.add(LoggedIn(user: user));
        yield RegisterInitial();

        // Close the registration screen
        Navigator.pop(context);
      } catch (error) {
        // Emit the failure state if an error occurs during registration
        yield RegisterFailure(error: error.toString());
      }
    }
    else if (event is RegisterButtonPressedDerm) {
      yield RegisterLoading();

      try {
        // Call the user repository to register the dermatologist
        await userRepository.dermRegister(
          username: event.username,
          email: event.email,
          password: event.password,
          phoneNumber: event.phoneNumber,
          firstName: event.firstName,
          lastName: event.lastName,
          qualification: event.qualification,
          clinic: event.clinic,
          specialization: event.specialization,
          hourlyRate: event.hourlyRate,
        );

        // Authenticate the registered dermatologist
        final user = await userRepository.authenticate(
          username: event.username,
          password: event.password,
        );

        // Emit the success state and trigger the authentication bloc's LoggedIn event
        authenticationBloc.add(LoggedIn(user: user));
        yield RegisterInitial();

        // Close the registration screen
        Navigator.pop(context);
      } catch (error) {
        // Emit the failure state if an error occurs during registration
        yield RegisterFailure(error: error.toString());
      }
    }
  }
}

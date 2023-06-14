import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:khungulanga_app/repositories/user_repository.dart';

import '../../models/clinic.dart';
import '../auth_bloc/auth_bloc.dart';

part 'register_event.dart';
part 'register_state.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  final UserRepository userRepository;
  final AuthBloc authenticationBloc;
  final BuildContext context;

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
        await userRepository.register(
          username: event.username,
          email: event.email,
          password: event.password,
          dob: event.dateOfBirth,
          firstName: event.firstName,
          lastName: event.lastName,
          gender: event.gender,
        );

        final user = await userRepository.authenticate(
          username: event.username,
          password: event.password,
        );

        authenticationBloc.add(LoggedIn(user: user));
        yield RegisterInitial();
        Navigator.pop(context);
      } catch (error) {
        yield RegisterFailure(error: error.toString());
      }
    }
    else if (event is RegisterButtonPressedDerm) {
      yield RegisterLoading();

      try {
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
          hourlyRate: event.hourlyRate
        );

        final user = await userRepository.authenticate(
          username: event.username,
          password: event.password,
        );

        authenticationBloc.add(LoggedIn(user: user));
        yield RegisterInitial();
        Navigator.pop(context);
      } catch (error) {
        yield RegisterFailure(error: error.toString());
      }
    }
  }
}

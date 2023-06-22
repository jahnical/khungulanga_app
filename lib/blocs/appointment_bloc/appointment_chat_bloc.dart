import 'dart:async';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:khungulanga_app/models/appointment.dart';
import 'package:khungulanga_app/repositories/appointment_repository.dart';
import 'package:khungulanga_app/repositories/user_repository.dart';
import 'package:meta/meta.dart';

import '../../models/appointment_chat.dart';
import '../../models/chat_message.dart';
import '../../models/dermatologist.dart';
import '../../models/diagnosis.dart';
import '../../models/patient.dart';

part 'appointment_chat_event.dart';
part 'appointment_chat_state.dart';

class AppointmentChatBloc extends Bloc<AppointmentChatEvent, AppointmentChatState> {
  final AppointmentRepository _appointmentChatRepository;
  final UserRepository _userRepository;

  AppointmentChat? chat;
  bool chatAppointmentIsDirty = false;

  AppointmentChatBloc(this._appointmentChatRepository, this._userRepository) : super(AppointmentChatInitial()) {}

  Future<AppointmentChat> _createAppointmentChat(FetchAppointmentChat event) async {
    final patient = await _userRepository.fetchPatient(USER!.username);
    return AppointmentChat(
      patient: patient,
      diagnosis: null,
      dermatologist: event.dermatologist!,
      messages: [],
      appointment: Appointment(
        dermatologist: event.dermatologist!,
        patient: patient,
        diagnosis: event.diagnosis,
      ),
    );
  }

  @override
  Stream<AppointmentChatState> mapEventToState(
    AppointmentChatEvent event,
  ) async* {
    log(event.toString());
    if (event is FetchAppointmentChat) {
      if (event.appointmentChatId == null) {
        final chat = await _createAppointmentChat(event);
        this.chat = await _appointmentChatRepository.saveAppointmentChat(chat);
        yield AppointmentChatLoaded(chat);
      } else {
        yield AppointmentChatLoading();
        try {
          final chat = await _appointmentChatRepository.getAppointmentChat(event.appointmentChatId!);
          log(event.diagnosis?.imageUrl ?? "No Image");
          chat.appointment = await _appointmentChatRepository.updateAppointment(chat.appointment);
          if (event.diagnosis != null) {
            chat.appointment.diagnosis = event.diagnosis;
            chat.appointment = await _appointmentChatRepository.updateAppointment(chat.appointment);
          }
          this.chat = chat;
          yield AppointmentChatLoaded(chat);
        } on DioError catch (e) {
          yield AppointmentChatError(message: e.response!.toString());
        }
      }
    }

    else if (event is SendMessage) {
      yield AppointmentChatMessageSending();
      try {
        final message = await _appointmentChatRepository.sendMessage(event.data);
        chat!.messages.add(message);
        yield AppointmentChatLoaded(chat!);
      } on DioError catch (e) {
        yield AppointmentChatError(message: e.response?.toString() ?? "Error Sending Message");
      }
    }

    else if (event is UpdateAppointment) {
      yield UpdatingAppointment();
      try {
        final appointment = await _appointmentChatRepository.updateAppointment(event.appointment);
        chat?.appointment = appointment;
        yield AppointmentUpdated(chat!);
        chatAppointmentIsDirty = false;
      } on DioError catch (e) {
        yield AppointmentUpdateError(message: e.response!.toString());
      }
    }

    else if (event is ApproveAppointment) {
      yield UpdatingAppointment();
      try {
        final appointment = chat!.appointment.copyWith();
        appointment.patientRemoved = DateTime.now();
        appointment.patientCancelled = null;
        chat?.appointment = await _appointmentChatRepository.updateAppointment(appointment);
        yield AppointmentUpdated(chat!);
      } on DioError catch (e) {
        yield AppointmentUpdateError(message: e.response!.toString());
      }
    }

    else if (event is RejectAppointment) {
      yield UpdatingAppointment();
      try {
        final appointment = chat!.appointment.copyWith();
        appointment.patientCancelled = DateTime.now();
        appointment.patientRemoved = null;
        chat?.appointment = await _appointmentChatRepository.updateAppointment(appointment);
        yield AppointmentUpdated(chat!);
      } on DioError catch (e) {
        yield AppointmentUpdateError(message: e.response!.toString());
      }
    }

    else if (event is FetchAppointmentChatMessages) {
      yield AppointmentChatLoading();
      try {
        final messages = await _appointmentChatRepository.getAppointmentChatMessages(event.appointmentChatId);
        chat!.messages = messages;
        yield AppointmentChatLoaded(chat!);
      } on DioError catch (e) {
        yield AppointmentChatError(message: e.response!.toString());
      }
    }
  }
}

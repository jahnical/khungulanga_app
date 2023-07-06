part of 'appointment_chat_bloc.dart';

@immutable
/// The base class for all appointment chat states.
/// Deprecated
abstract class AppointmentChatState {}

class AppointmentChatInitial extends AppointmentChatState {}

class AppointmentChatLoading extends AppointmentChatState {}

class AppointmentChatLoaded extends AppointmentChatState {
  final AppointmentChat appointmentChat;

  AppointmentChatLoaded(this.appointmentChat);
}

class AppointmentChatError extends AppointmentChatState {
  final String message;
  AppointmentChatError({required this.message});
}

class AppointmentChatMessageSending extends AppointmentChatState {}

class AppointmentChatMessageSent extends AppointmentChatState {
  final ChatMessage appointmentChatMessage;

  AppointmentChatMessageSent(this.appointmentChatMessage);
}

class AppointmentChatMessageSendingError extends AppointmentChatState {
  final String message;
  AppointmentChatMessageSendingError({required this.message});
}

class AppointmentUpdated extends AppointmentChatState {
  final AppointmentChat appointmentChat;

  AppointmentUpdated(this.appointmentChat);
}

class UpdatingAppointment extends AppointmentChatState {}

class AppointmentUpdateError extends AppointmentChatState {
  final String message;
  AppointmentUpdateError({required this.message});
}


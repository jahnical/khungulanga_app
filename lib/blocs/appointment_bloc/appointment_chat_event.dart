part of 'appointment_chat_bloc.dart';

@immutable
abstract class AppointmentChatEvent {}

class FetchAppointmentChat extends AppointmentChatEvent {
  final int? appointmentChatId;
  final Dermatologist? dermatologist;
  final Patient? patient;
  final BuildContext? context;
  final Diagnosis? diagnosis;

  FetchAppointmentChat(this.appointmentChatId, this.dermatologist, this.patient, this.context, this.diagnosis);
}

class SendMessage extends AppointmentChatEvent {
  final FormData data;

  SendMessage(this.data);
}

class ApproveAppointment extends AppointmentChatEvent {}

class RejectAppointment extends AppointmentChatEvent {}

class CancelAppointment extends AppointmentChatEvent {}

class UpdateAppointment extends AppointmentChatEvent {
  late Appointment appointment;
  UpdateAppointment(this.appointment);
}

class FetchAppointmentChatMessages extends AppointmentChatEvent {
  final int appointmentChatId;

  FetchAppointmentChatMessages(this.appointmentChatId);
}

class FetchAppointmentChats extends AppointmentChatEvent {}


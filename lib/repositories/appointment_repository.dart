import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:khungulanga_app/models/appointment.dart';
import 'package:khungulanga_app/models/chat_message.dart';

import '../api_connection/api_client.dart';
import '../api_connection/con_options.dart';
import '../api_connection/endpoints.dart';
import '../models/appointment_chat.dart';

class AppointmentRepository {
  final Dio _dio = APIClient.dio;

  /// Retrieves a list of appointment chats from the API.
  ///
  /// Returns a list of [AppointmentChat] objects representing the appointment chats.
  Future<List<AppointmentChat>> getAppointmentChats() async {
    final response = await _dio.get('$APPOINTMENT_CHAT_URL/', options: getOptions());
    final chatsJson = response.data as List<dynamic>;
    final chats = chatsJson.map((chatJson) => AppointmentChat.fromJson(chatJson)).toList();
    return chats;
  }

  /// Retrieves a list of appointments from the API.
  ///
  /// [completed] specifies whether to fetch completed or pending appointments.
  /// [cancelled] specifies whether to include cancelled appointments (default is false).
  /// Returns a list of [Appointment] objects representing the appointments.
  Future<List<Appointment>> getAppointments(bool completed, {bool cancelled = false}) async {
    final response = await _dio.get('$APPOINTMENTS_URL/?done=$completed&cancelled=$cancelled', options: getOptions());
    final appointmentsJson = response.data as List<dynamic>;
    final appointments = appointmentsJson.map((appointmentJson) => Appointment.fromJson(appointmentJson)).toList();
    return appointments;
  }

  /// Retrieves an appointment chat by its ID from the API.
  ///
  /// [id] is the ID of the appointment chat.
  /// Returns an [AppointmentChat] object representing the appointment chat.
  Future<AppointmentChat> getAppointmentChat(int id) async {
    final response = await _dio.get('$APPOINTMENT_CHAT_URL/$id/', options: getOptions());
    final chatJson = response.data as Map<String, dynamic>;
    final chat = AppointmentChat.fromJson(chatJson);
    return chat;
  }

  /// Saves an appointment chat to the API.
  ///
  /// [chat] is the appointment chat to be saved.
  /// Returns the created [AppointmentChat] object.
  Future<AppointmentChat> saveAppointmentChat(AppointmentChat chat) async {
    final response = await _dio.post('$APPOINTMENT_CHAT_URL/', options: postOptions(), data: chat.toJsonMap());

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('Failed to create appointment chat');
    } else {
      final chatJson = response.data as Map<String, dynamic>;
      log(chatJson.toString());
      final createdChat = AppointmentChat.fromJson(chatJson);
      return createdChat;
    }
  }

  /// Sends a chat message to the API.
  ///
  /// [data] contains the chat message data to be sent.
  /// Returns the sent [ChatMessage] object.
  Future<ChatMessage> sendMessage(FormData data) async {
    final response = await _dio.post('$CHAT_MESSAGES_URL/', options: postOptions(), data: data);

    if (response.statusCode != 201) {
      throw Exception('Failed to send message');
    } else {
      final messageJson = response.data as Map<String, dynamic>;
      final message = ChatMessage.fromJson(messageJson);
      return message;
    }
  }

  /// Retrieves a list of chat messages for an appointment chat from the API///
  /// [appointmentChatId] is the ID of the appointment chat.
  /// Returns a list of [ChatMessage] objects representing the chat messages.
  Future<List<ChatMessage>> getAppointmentChatMessages(int appointmentChatId) async {
    final response = await _dio.get('$APPOINTMENT_CHAT_URL/$appointmentChatId/messages/', options: getOptions());

    if (response.statusCode != 200) {
      throw Exception('Failed to get appointment chat messages');
    } else {
      final messagesJson = response.data as List<dynamic>;
      final messages = messagesJson.map((messageJson) => ChatMessage.fromJson(messageJson)).toList();
      return messages;
    }
  }

  /// Updates an appointment in the API.
  ///
  /// [appointment] is the updated appointment object.
  /// Returns the updated [Appointment] object.
  Future<Appointment> updateAppointment(Appointment appointment) async {
    log(appointment.extraInfo);
    final response = await _dio.put('$APPOINTMENTS_URL/${appointment.id}/', options: putOptions(), data: appointment.toJson());

    if (response.statusCode != 200) {
      throw Exception('Failed to update appointment');
    } else {
      final appointmentJson = response.data as Map<String, dynamic>;
      final updatedAppointment = Appointment.fromJson(appointmentJson);
      return updatedAppointment;
    }
  }

  /// Books a new appointment in the API.
  ///
  /// [appointment] is the appointment object to be booked.
  /// Returns the booked [Appointment] object.
  Future<Appointment> bookAppointment(Appointment appointment) async {
    final response = await _dio.post('$APPOINTMENTS_URL/', options: postOptions(), data: appointment.toJson());

    if (response.statusCode != 201) {
      throw Exception('Failed to book appointment');
    } else {
      final appointmentJson = response.data as Map<String, dynamic>;
      final bookedAppointment = Appointment.fromJson(appointmentJson);
      return bookedAppointment;
    }
  }

  /// Retrieves an appointment by its ID from the API.
  ///
  /// [i] is the ID of the appointment.
  /// Returns an [Appointment] object representing the appointment.
  Future<Appointment> getAppointment(int i) async {
    final response = await _dio.get('$APPOINTMENTS_URL/$i/', options: getOptions());

    if (response.statusCode != 200) {
      throw Exception('Failed to get appointment');
    } else {
      final appointmentJson = response.data as Map<String, dynamic>;
      final appointment = Appointment.fromJson(appointmentJson);
      return appointment;
    }
  }
}

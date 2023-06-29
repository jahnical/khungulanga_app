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
  // This could be replaced with an API call or database querry
  Future<List<AppointmentChat>> getAppointmentChats() async {
    final response = await _dio.get('$APPOINTMENT_CHAT_URL/', options: getOptions());
    final chatsJson = response.data as List<dynamic>;
    final chats = chatsJson.map((chatJson) => AppointmentChat.fromJson(chatJson)).toList();
    return chats;
  }

  Future<List<Appointment>> getAppointments(bool completed, {bool cancelled=false}) async {
    final response = await _dio.get('$APPOINTMENTS_URL/?done=$completed&cancelled=$cancelled', options: getOptions());
    final appointmentsJson = response.data as List<dynamic>;
    final appointments = appointmentsJson.map((appointmentJson) => Appointment.fromJson(appointmentJson)).toList();

    return appointments;
  }

  Future<AppointmentChat> getAppointmentChat(int id) async {
    final response = await _dio.get('$APPOINTMENT_CHAT_URL/$id/', options: getOptions());
    final chatJson = response.data as Map<String, dynamic>;
    final chat = AppointmentChat.fromJson(chatJson);
    return chat;
  }
// appointment
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
//when patient wants to communicate with dermatologist
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
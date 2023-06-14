import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:khungulanga_app/models/slot.dart';
import '../api_connection/api_client.dart';
import '../api_connection/con_options.dart';
import '../api_connection/endpoints.dart';

class SlotRepository {
  final Dio _dio = APIClient.dio;

  Future<List<Slot>> getSlots() async {
    final response = await _dio.get('$SLOTS_URL/', options: getOptions());
    final slotsJson = response.data as List<dynamic>;
    final slots = slotsJson.map((slotJson) => Slot.fromJson(slotJson)).toList();
    return slots;
  }

  Future<Slot> getSlot(int id) async {
    final response = await _dio.get('$SLOTS_URL/$id/', options: getOptions());
    final slotJson = response.data as Map<String, dynamic>;
    final slot = Slot.fromJson(slotJson);
    return slot;
  }

  Future<Slot> saveSlot(Slot slot) async {
    final response = await _dio.post('$SLOTS_URL/', options: postOptions(), data: slot.toJson());

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('Failed to create slot');
    } else {
      final slotJson = response.data as Map<String, dynamic>;
      log(slotJson.toString());
      final createdSlot = Slot.fromJson(slotJson);
      return createdSlot;
    }
  }

  Future<Slot> updateSlot(Slot slot) async {
    final response = await _dio.put('$SLOTS_URL/${slot.id}/', options: putOptions(), data: slot.toJson());

    if (response.statusCode != 200) {
      throw Exception('Failed to update slot');
    } else {
      final slotJson = response.data as Map<String, dynamic>;
      final updatedSlot = Slot.fromJson(slotJson);
      return updatedSlot;
    }
  }

  Future<void> deleteSlot(int id) async {
    final response = await _dio.delete('$SLOTS_URL/$id/', options: deleteOptions());

    if (response.statusCode != 204) {
      throw Exception('Failed to delete slot');
    }
  }
}

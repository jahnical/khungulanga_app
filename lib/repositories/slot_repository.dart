import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:khungulanga_app/models/slot.dart';
import '../api_connection/api_client.dart';
import '../api_connection/con_options.dart';
import '../api_connection/endpoints.dart';

/// Repository for managing slot-related data and operations.
class SlotRepository {
  final Dio _dio = APIClient.dio;

  /// Retrieves a list of all slots.
  ///
  /// Returns a list of [Slot] objects representing the slots.
  Future<List<Slot>> getSlots() async {
    final response = await _dio.get('$SLOTS_URL/', options: getOptions());
    final slotsJson = response.data as List<dynamic>;
    final slots = slotsJson.map((slotJson) => Slot.fromJson(slotJson)).toList();
    return slots;
  }

  /// Retrieves a list of slots for a specific dermatologist.
  ///
  /// [dermId] represents the ID of the dermatologist.
  /// Returns a list of [Slot] objects representing the slots.
  Future<List<Slot>> getSlotsOf(int dermId) async {
    final response = await _dio.get('$SLOTS_URL/of/$dermId/', options: getOptions());
    final slotsJson = response.data as List<dynamic>;
    final slots = slotsJson.map((slotJson) => Slot.fromJson(slotJson)).toList();
    return slots;
  }

  /// Retrieves a slot by its ID.
  ///
  /// [id] represents the ID of the slot.
  /// Returns a [Slot] object representing the slot.
  Future<Slot> getSlot(int id) async {
    final response = await _dio.get('$SLOTS_URL/$id/', options: getOptions());
    final slotJson = response.data as Map<String, dynamic>;
    final slot = Slot.fromJson(slotJson);
    return slot;
  }

  /// Saves a new slot.
  ///
  /// [slot] represents the slot to be saved.
  /// Returns the created [Slot] object.
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

  /// Updates an existing slot.
  ///
  /// [slot] represents the updated slot.
  /// Returns the updated [Slot] object.
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

  /// Deletes a slot by its ID.
  ///
  /// [id] represents the ID of the slot to be deleted.
  Future<void> deleteSlot(int id) async {
    final response = await _dio.delete('$SLOTS_URL/$id/', options: deleteOptions());

    if (response.statusCode != 204) {
      throw Exception('Failed to delete slot');
    }
  }
}

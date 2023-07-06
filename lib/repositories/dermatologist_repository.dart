import 'package:dio/dio.dart';
import 'package:khungulanga_app/models/dermatologist.dart';
import 'package:khungulanga_app/api_connection/endpoints.dart';
import 'package:khungulanga_app/api_connection/con_options.dart';

import '../api_connection/api_client.dart';

/// Repository class for managing dermatologists.
class DermatologistRepository {
  final Dio _dio = APIClient.dio;

  /// Retrieves a list of all dermatologists.
  ///
  /// Returns a list of [Dermatologist] objects representing the dermatologists.
  Future<List<Dermatologist>> getDermatologists() async {
    final response = await _dio.get('$DERMATOLOGISTS_URL/', options: getOptions());
    final dermatologistsJson = response.data as List<dynamic>;
    final dermatologists = dermatologistsJson
        .map((json) => Dermatologist.fromJson(json as Map<String, dynamic>))
        .toList();
    return dermatologists;
  }

  /// Retrieves a dermatologist by their ID.
  ///
  /// [id] represents the ID of the dermatologist.
  /// Returns a [Dermatologist] object representing the dermatologist.
  Future<Dermatologist> getDermatologistById(int id) async {
    final response = await _dio.get('$DERMATOLOGISTS_URL/$id/', options: getOptions());
    final dermatologistJson = response.data as Map<String, dynamic>;
    final dermatologist = Dermatologist.fromJson(dermatologistJson);
    return dermatologist;
  }

  /// Updates a dermatologist.
  ///
  /// [dermatologist] represents the dermatologist to be updated.
  Future<void> updateDermatologist(Dermatologist dermatologist) async {
    final response = await _dio.put('$DERMATOLOGISTS_URL/${dermatologist.user.username}/', data: dermatologist.toJson(), options: putOptions());

    if (response.statusCode != 200) {
      throw Exception('Failed to update dermatologist.');
    } else {
      print('Dermatologist updated successfully.');
    }
  }

  /// Deletes a dermatologist.
  ///
  /// [id] represents the ID of the dermatologist to be deleted.
  Future<void> deleteDermatologist(int id) async {
    await _dio.delete('$DERMATOLOGISTS_URL/$id');
  }

  /// Retrieves a list of nearby dermatologists based on latitude and longitude.
  ///
  /// [latitude] represents the latitude coordinate.
  /// [longitude] represents the longitude coordinate.
  /// Returns a list of [Dermatologist] objects representing the nearby dermatologists.
  Future<List<Dermatologist>> getNearbyDermatologists(latitude, longitude) async {
    final response = await _dio.get('$DERMATOLOGISTS_URL/nearby?latitude=$latitude&longitude=$longitude', options: getOptions());
    final dermatologistsJson = response.data as List<dynamic>;
    final dermatologists = dermatologistsJson
        .map((json) => Dermatologist.fromJson(json as Map<String, dynamic>))
        .toList();
    return dermatologists;
  }
}

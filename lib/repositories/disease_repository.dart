import 'package:dio/dio.dart';
import 'package:khungulanga_app/models/disease.dart';
import 'package:khungulanga_app/api_connection/endpoints.dart';
import 'package:khungulanga_app/api_connection/con_options.dart';

import '../api_connection/api_client.dart';

/// Repository class for managing diseases.
class DiseaseRepository {
  final Dio _dio = APIClient.dio;

  /// Retrieves a list of all diseases.
  ///
  /// Returns a list of [Disease] objects representing the diseases.
  Future<List<Disease>> getDiseases() async {
    final response = await _dio.get('$DISEASES_URL/', options: getOptions());
    final diseasesJson = response.data as List<dynamic>;
    final diseases = diseasesJson
        .map((json) => Disease.fromJson(json as Map<String, dynamic>))
        .toList();
    return diseases;
  }

  /// Retrieves a disease by its ID.
  ///
  /// [id] represents the ID of the disease.
  /// Returns a [Disease] object representing the disease.
  Future<Disease> getDiseaseById(int id) async {
    final response = await _dio.get('$DISEASES_URL/$id/', options: getOptions());
    final diseaseJson = response.data as Map<String, dynamic>;
    final disease = Disease.fromJson(diseaseJson);
    return disease;
  }

  /*Future<Disease> createDisease(Disease disease) async {
    final response = await _dio.post('https://example.com/diseases',
        data: jsonEncode(disease.toJson()));
    final diseaseJson = response.data as Map<String, dynamic>;
    final createdDisease = Disease.fromJson(diseaseJson);
    return createdDisease;
  }

  Future<void> updateDisease(int id, Disease disease) async {
    await _dio.put('https://example.com/diseases/$id',
        data: jsonEncode(disease.toJson()));
  }*/

  /// Deletes a disease by its ID.
  ///
  /// [id] represents the ID of the disease to be deleted.
  Future<void> deleteDisease(int id) async {
    await _dio.delete('$DISEASES_URL/$id');
  }

  /// Retrieves a list of severe diseases.
  ///
  /// Returns a list of [Disease] objects representing the severe diseases.
  Future<List<Disease>> getSevereDiseases() async {
    final response = await _dio.get('$DISEASES_URL/severe', options: getOptions());
    final diseasesJson = response.data as List<dynamic>;
    final diseases = diseasesJson
        .map((json) => Disease.fromJson(json as Map<String, dynamic>))
        .toList();
    return diseases;
  }
}

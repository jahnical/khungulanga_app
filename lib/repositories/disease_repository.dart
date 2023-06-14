import 'package:dio/dio.dart';
import 'package:khungulanga_app/models/disease.dart';
import 'package:khungulanga_app/api_connection/endpoints.dart';
import 'package:khungulanga_app/api_connection/con_options.dart';

import '../api_connection/api_client.dart';

class DiseaseRepository {
  final Dio _dio = APIClient.dio;

  Future<List<Disease>> getDiseases() async {
    final response = await _dio.get('$DISEASES_URL/', options: getOptions());
    final diseasesJson = response.data as List<dynamic>;
    final diseases = diseasesJson
        .map((json) => Disease.fromJson(json as Map<String, dynamic>))
        .toList();
    return diseases;
  }

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

  Future<void> deleteDisease(int id) async {
    await _dio.delete('$DISEASES_URL/$id');
  }

  Future<List<Disease>> getSevereDiseases() async {
    final response = await _dio.get('$DISEASES_URL/severe', options: getOptions());
    final diseasesJson = response.data as List<dynamic>;
    final diseases = diseasesJson
        .map((json) => Disease.fromJson(json as Map<String, dynamic>))
        .toList();
    return diseases;
  }
}
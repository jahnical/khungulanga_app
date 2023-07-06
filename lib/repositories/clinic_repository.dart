import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';

import '../api_connection/api_client.dart';
import '../api_connection/con_options.dart';
import '../api_connection/endpoints.dart';
import '../models/clinic.dart';

class ClinicRepository {
  final Dio _dio = APIClient.dio;
  final url = 'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location={USER_LATITUDE},{USER_LONGITUDE}&radius=5000&type=clinic&key=YOUR_API_KEY';
  List<Clinic> _clinics = [];

  /// Constructs a new [ClinicRepository] instance.
  ///
  /// Initializes the repository by fetching clinics.
  ClinicRepository() {
    fetchClinics();
  }

  /// Fetches the list of clinics.
  ///
  /// If the clinics list is not empty, returns the cached list.
  /// Otherwise, retrieves the clinics from the API.
  Future<List<Clinic>> fetchClinics() async {
    if (_clinics.isNotEmpty) {
      return _clinics;
    }
    _clinics = await getClinics();
    return _clinics;
  }

  /// Retrieves the list of clinics from the API.
  ///
  /// Returns a list of [Clinic] objects representing the clinics.
  /// Throws an exception if the API request fails.
  Future<List<Clinic>> getClinics() async {
    final response = await _dio.get('$CLINICS_URL/', options: getOptions());

    if (response.statusCode == 200) {
      final clinicsJson = response.data as List<dynamic>;
      final clinics = clinicsJson
          .map((json) => Clinic.fromJson(json as Map<String, dynamic>))
          .toList();
      return clinics;
    } else {
      log(response.toString());
      throw Exception('Failed to fetch clinics');
    }
  }
}

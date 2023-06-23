
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

  ClinicRepository() {
    fetchClinics();
  }
  Future<List<Clinic>> fetchClinics() async {
    if (_clinics.isNotEmpty) {
      return _clinics;
    }
    _clinics = await getClinics();
    return _clinics;
    /*return [
      Clinic(name: "Songani", latitude: 23.778695, longitude: 12.543235, id: 1),
      Clinic(name: "Songani1", latitude: 23.778695, longitude: 12.543235, id: 2),
      Clinic(name: "Songani2", latitude: 23.778695, longitude: 12.543235, id: 3),
    ];
    final response = await _dio.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.data);

      List<Clinic> clinics = [];
      for (var result in data['results']) {
        clinics.add(Clinic(
          name: result['name'],
          latitude: result['geometry']['location']['lat'],
          longitude: result['geometry']['location']['lng'],
        ));
      }
      return clinics;
    } else {
      throw Exception('Failed to fetch clinics');
    }*/
  }

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
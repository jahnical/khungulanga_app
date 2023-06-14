
import 'dart:convert';

import 'package:dio/dio.dart';

import '../api_connection/api_client.dart';
import '../models/clinic.dart';

class ClinicRepository {
  final Dio _dio = APIClient.dio;
  final url = 'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location={USER_LATITUDE},{USER_LONGITUDE}&radius=5000&type=clinic&key=YOUR_API_KEY';
  Future<List<Clinic>> fetchClinics() async {
    return [
      Clinic(name: "Songani", latitude: 23.778695, longitude: 12.543235),
      Clinic(name: "Songani1", latitude: 23.778695, longitude: 12.543235),
      Clinic(name: "Songani2", latitude: 23.778695, longitude: 12.543235)
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
    }
  }

}
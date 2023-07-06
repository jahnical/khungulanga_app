import 'package:dio/dio.dart';
import 'package:khungulanga_app/models/patient.dart';
import 'package:khungulanga_app/api_connection/endpoints.dart';
import 'package:khungulanga_app/api_connection/con_options.dart';

import '../api_connection/api_client.dart';

/// Repository for managing patient-related data and operations.
class PatientRepository {
  final Dio _dio = APIClient.dio;

  /// Retrieves a list of all patients.
  ///
  /// Returns a list of [Patient] objects representing the patients.
  Future<List<Patient>> getPatients() async {
    final response = await _dio.get('$PATIENTS_URL/', options: getOptions());
    final patientsJson = response.data as List<dynamic>;
    final patients = patientsJson
        .map((json) => Patient.fromJson(json as Map<String, dynamic>))
        .toList();
    return patients;
  }

  /// Retrieves a patient by their ID.
  ///
  /// [id] represents the ID of the patient.
  /// Returns a [Patient] object representing the patient.
  Future<Patient> getPatientById(int id) async {
    final response = await _dio.get('$PATIENTS_URL/$id/', options: getOptions());
    final patientJson = response.data as Map<String, dynamic>;
    final patient = Patient.fromJson(patientJson);
    return patient;
  }

  /// Updates a patient.
  ///
  /// [patient] represents the updated patient.
  Future<void> updatePatient(Patient patient) async {
    final response = await _dio.put('$PATIENTS_URL/${patient.user?.username}/', data: patient.toJson(), options: putOptions());

    if (response.statusCode != 200) {
      throw Exception('Failed to update patient.');
    } else {
      print('Patient updated successfully.');
    }
  }

  /// Deletes a patient by their ID.
  ///
  /// [id] represents the ID of the patient to be deleted.
  Future<void> deletePatient(int id) async {
    await _dio.delete('$PATIENTS_URL/$id');
  }

  /// Retrieves a list of patients near a specific location.
  ///
  /// [latitude] represents the latitude of the location.
  /// [longitude] represents the longitude of the location.
  /// Returns a list of [Patient] objects representing the nearby patients.
  Future<List<Patient>> getNearbyPatients(double latitude, double longitude) async {
    final response = await _dio.get('$PATIENTS_URL/nearby?latitude=$latitude&longitude=$longitude', options: getOptions());
    final patientsJson = response.data as List<dynamic>;
    final patients = patientsJson
        .map((json) => Patient.fromJson(json as Map<String, dynamic>))
        .toList();
    return patients;
  }
}

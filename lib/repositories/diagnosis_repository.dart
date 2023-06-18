import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:khungulanga_app/models/diagnosis.dart';
import 'package:khungulanga_app/api_connection/endpoints.dart';
import 'package:khungulanga_app/models/prediction.dart';

import '../api_connection/api_client.dart';
import '../api_connection/con_options.dart';
import '../util/common.dart';

class DiagnosisRepository {
  final Dio _dio = APIClient.dio;
  List<Diagnosis> diagnoses = [];

  Future<List<Diagnosis>> fetchDiagnoses() async {
    try {
      final response = await _dio.get("$DIAGNOSIS_URL/", options: getOptions());
      final data = response.data as List<dynamic>;
      diagnoses = data.map((e) => Diagnosis.fromJson(e)).toList();
      return diagnoses;
    } on DioError catch (e) {
      log(e.toString());
      throw Exception(e.message);
    }
  }

  Future<Diagnosis> diagnose(FormData data) async {
    final dio = Dio();

    log(DIAGNOSIS_URL);

    try {
      final Response response = await dio.post(
        "$DIAGNOSIS_URL/",
        options: postOptions(),
        data: data,
      );
      if (response.statusCode == 200) {
        return Diagnosis.fromJson(response.data);
      } if (response.statusCode == 206) {
        throw AppException("No skin detected, make sure the image is clear and the skin covers at least half of it.", "206");
      } else {
        log(response.data.toString());
        throw Exception(response.data.toString());
      }
    } on DioError catch (e) {
      log(e.toString());
      if (e.response?.statusCode == 400) {
        throw AppException("Unable to diagnose, please try again.", "400");
      } else {
        throw Exception(e.message);
      }
      rethrow;
    }
  }

  Future<Diagnosis> updateDiagnosis(Diagnosis diagnosis) async {
    final response = await _dio.put('$DIAGNOSIS_URL/${diagnosis.id}', options: putOptions(), data: jsonEncode(diagnosis.toJson()));

    if (response.statusCode != 200) {
      throw Exception('Failed to update diagnosis');
    } else {
      final diagnosisJson = response.data as Map<String, dynamic>;
      final diagnosis = Diagnosis.fromJson(diagnosisJson);
      return diagnosis;
    }
  }

  Future<bool> delete(Diagnosis diagnosis) async {
    try {
      await _dio.delete("$DIAGNOSIS_URL/${diagnosis.id}", options: getOptions());
      diagnoses.remove(diagnosis);
      return true;
    } on DioError catch (e) {
      throw Exception(e.message);
    }
  }

  Future<Prediction> updatePrediction(Prediction prediction) async {
    final response = await _dio.put('$PREDICTION_URL/${prediction.id}/', options: putOptions(), data: jsonEncode(prediction.toJson()));

    if (response.statusCode != 200) {
      throw Exception('Failed to update prediction');
    } else {
      final predictionJson = response.data as Map<String, dynamic>;
      final prediction = Prediction.fromJson(predictionJson);
      return prediction;
    }
  }

  getDiagnosis(int id) {
    return diagnoses.firstWhere((diagnosis) => diagnosis.id == id);
  }
}

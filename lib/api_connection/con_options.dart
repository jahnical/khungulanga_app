import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:khungulanga_app/repositories/user_repository.dart';

/// Returns [Options] object with headers for a POST request.
Options postOptions() {
  return Options(headers: <String, String>{
    'Content-Type': 'application/json; charset=UTF-8',
    'Authorization': 'Token ${USER?.token}'
  });
}

/// Returns [Options] object with headers for a GET request.
Options getOptions() {
  log(USER?.token ?? "No Token");
  return Options(headers: <String, String>{
    "Authorization": 'Token ${USER?.token}'
  });
}

/// Returns [Options] object with headers for a PATCH request.
Options patchOptions() {
  return Options(headers: <String, String>{
    'Content-Type': 'application/json; charset=UTF-8',
    "Authorization": 'Token ${USER?.token}'
  });
}

/// Returns [Options] object with headers for a PUT request.
Options putOptions() {
  return Options(headers: <String, String>{
    'Content-Type': 'application/json; charset=UTF-8',
    "Authorization": 'Token ${USER?.token}'
  });
}

/// Returns [Options] object with headers for a DELETE request.
Options deleteOptions() {
  return Options(headers: <String, String>{
    'Content-Type': 'application/json; charset=UTF-8',
    "Authorization": 'Token ${USER?.token}'
  });
}

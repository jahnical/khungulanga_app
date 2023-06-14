import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:khungulanga_app/repositories/user_repository.dart';

Options postOptions() {
  return Options(headers: <String, String>{
    'Content-Type': 'application/json; charset=UTF-8',
    'Authorization': 'Token ${USER?.token}'
  });
}

Options getOptions() {
  log(USER?.token ?? "No Token");
  return Options(headers: <String, String> {
    "Authorization": 'Token ${USER?.token}'
  });
}

Options patchOptions() {
  return Options(headers: <String, String> {
    'Content-Type': 'application/json; charset=UTF-8',
    "Authorization": 'Token ${USER?.token}'
  });
}

Options putOptions() {
  return Options(headers: <String, String> {
    'Content-Type': 'application/json; charset=UTF-8',
    "Authorization": 'Token ${USER?.token}'
  });
}

Options deleteOptions() {
  return Options(headers: <String, String> {
    'Content-Type': 'application/json; charset=UTF-8',
    "Authorization": 'Token ${USER?.token}'
  });
}
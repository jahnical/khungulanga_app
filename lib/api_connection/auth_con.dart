import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:khungulanga_app/models/auth_user.dart';
import 'package:khungulanga_app/api_connection/endpoints.dart';


Future<Token> getToken(UserLogin userLogin) async {
  final dio = Dio();

  log(TOKEN_URL);

  final Response response = await dio.post(
    TOKEN_URL,
    options: Options(headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    }),
    data: jsonEncode(userLogin.toDatabaseJson()),
  );

  if (response.statusCode == 200) {
    return Token.fromJson(response.data);
  } else {
    log(response.data.toString());
    throw Exception(response.data.toString());
  }
}

Future<void> registerUser(UserRegister userRegister) async {
  final dio = Dio();

  log(REGISTER_URL);

  final Response response = await dio.post(
    REGISTER_URL,
    options: Options(headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    }),
    data: jsonEncode(userRegister.toDatabaseJson()),
  );

  if (response.statusCode == 201) {
    log("User created successfully");
  } else {
    log(response.data.toString());
    throw Exception(response.data.toString());
  }
}

Future<void> registerDermUser(DermUserRegister userRegister) async {
  final dio = Dio();

  log(DERM_REGISTER_URL);
  final dermJson = userRegister.toDatabaseJson();
  dermJson["qualification"] = await MultipartFile.fromFile(dermJson["qualification"]);
  final Response response = await dio.post(
    DERM_REGISTER_URL,
    options: Options(headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    }),
    data: FormData.fromMap(dermJson, ListFormat.multiCompatible),
  );

  if (response.statusCode == 201) {
    log("User created successfully");
  } else {
    log(response.data.toString());
    throw Exception(response.data.toString());
  }
}


import 'dart:async';
import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:khungulanga_app/models/patient.dart';
import 'package:khungulanga_app/models/user.dart';
import 'package:meta/meta.dart';
import 'package:khungulanga_app/api_connection/auth_con.dart';
import 'package:khungulanga_app/dao/user_dao.dart';
import 'package:khungulanga_app/models/auth_user.dart';

import '../api_connection/api_client.dart';
import '../api_connection/con_options.dart';
import '../api_connection/endpoints.dart';
import '../models/clinic.dart';
import '../models/dermatologist.dart';

AuthUser? USER;
class UserRepository {
  final userDao = UserDao();
  Patient? patient;
  Dermatologist? dermatologist;
  final _dio = APIClient.dio;

  Future<AuthUser> authenticate ({
    required String username,
    required String password,
  }) async {
    UserLogin userLogin = UserLogin(
        username: username,
        password: password
    );
    Token token = await getToken(userLogin);
    AuthUser user = AuthUser(
      id: 0,
      username: username,
      token: token.token,
    );
    try {
      await fetchPatient(user.username);
    } catch (dioe) {
      log(dioe.toString());
    }
    try {
      await fetchDermatologist(user.username);
    } catch (dioe) {
      log(dioe.toString());
    }
    return user;
  }

  Future<Patient> fetchPatient(String username) async {
    if (this.patient != null) return this.patient!;
    final response = await _dio.get('$PATIENTS_URL/$username/', options: getOptions());
    final patientJson = response.data as Map<String, dynamic>;
    final patient = Patient.fromJson(patientJson);
    this.patient = patient;
    return patient;
  }

  Future<void> persistToken ({
    required AuthUser user
  }) async {
    // write token with the user to the database
    await userDao.createUser(user);
  }

  Future<AuthUser?> getUserFromDB() async {
    AuthUser? user = await userDao.getToken(0);
    USER = user;
    if (user != null) {
      try {
        await fetchPatient(user.username);
      } catch (dioe) {
        log(dioe.toString());
      }
      try {
        await fetchDermatologist(user.username);
      } catch (dioe) {
        log(dioe.toString());
      }
    }
    return user;
  }

  Future <void> deleteToken({
    required int id
  }) async {
    await userDao.deleteUser(id);
    USER = null;
    this.patient = null;
  }

  Future <bool> hasToken() async {
    bool result = await userDao.checkUser(0);
    return result;
  }

  Future<UserRegister> register(
      {required String username,
      required String email,
      required String password,
      required String firstName,
      required String lastName,
      required DateTime dob,
      required String gender}) async {
    // create a UserRegister object with the necessary fields
    final userRegister = UserRegister(
        username: username,
        password: password,
        firstName: firstName,
        lastName: lastName,
        dob: dob,
        email: email,
        gender: gender);

    await registerUser(userRegister);
    
    return userRegister;
  }

  Future<Dermatologist> fetchDermatologist(String username) async {
    if (this.dermatologist != null) return this.dermatologist!;
    final response =
    await _dio.get('$DERMATOLOGISTS_URL/$username/', options: getOptions());
    final dermatologistJson = response.data as Map<String, dynamic>;
    final dermatologist = Dermatologist.fromJson(dermatologistJson);
    this.dermatologist = dermatologist;
    return dermatologist;
  }

  Future<DermUserRegister> dermRegister(
      {required String username,
        required String email,
        required String password,
        required String firstName,
        required String lastName,
        required String phoneNumber,
        required String qualification,
        required Clinic clinic,
        required String specialization,
        required  double hourlyRate
      }) async {
    // create a UserRegister object with the necessary fields
    final userRegister = DermUserRegister(
      username: username,
      password: password,
      firstName: firstName,
      lastName: lastName,
      email: email,
      phoneNumber:   phoneNumber,
      qualification: qualification,
      clinic:        clinic,
      specialization: specialization,
      hourlyRate: hourlyRate
    );

    await registerDermUser(userRegister);

    return userRegister;
  }
}
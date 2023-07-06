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
/// Repository for managing user-related data and operations.
class UserRepository {
  final userDao = UserDao();
  Patient? patient;
  Dermatologist? dermatologist;
  final _dio = APIClient.dio;

  /// Authenticates the user with the provided credentials.
  ///
  /// Returns an [AuthUser] object representing the authenticated user.
  /// Throws an error if authentication fails.
  Future<AuthUser> authenticate({
    required String username,
    required String password,
  }) async {
    UserLogin userLogin = UserLogin(
      username: username,
      password: password,
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

  /// Fetches the patient associated with the given username.
  ///
  /// Returns a [Patient] object representing the patient.
  /// If the patient is already fetched, returns the existing instance.
  Future<Patient> fetchPatient(String username) async {
    if (this.patient != null) return this.patient!;
    final response =
    await _dio.get('$PATIENTS_URL/$username/', options: getOptions());
    final patientJson = response.data as Map<String, dynamic>;
    final patient = Patient.fromJson(patientJson);
    this.patient = patient;
    return patient;
  }

  /// Persists the user token to the database.
  ///
  /// [user] represents the authenticated user.
  Future<void> persistToken({
    required AuthUser user,
  }) async {
    // write token with the user to the database
    await userDao.createUser(user);
  }

  /// Retrieves the user token from the database.
  ///
  /// Returns an [AuthUser] object representing the user if found, otherwise returns null.
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

  /// Deletes the user token from the database.
  ///
  /// [id] specifies the ID of the user token to delete.
  Future<void> deleteToken({
    required int id,
  }) async {
    await userDao.deleteUser(id);
    USER = null;
    this.patient = null;
    this.dermatologist = null;
  }

  /// Checks if a user token exists in the database.
  ///
  /// Returns true if a user token exists, false otherwise.
  Future<bool> hasToken() async {
    bool result = await userDao.checkUser(0);
    return result;
  }

  /// Registers a new user.
  ///
  /// [username] represents the username of the user.
  /// [email] represents the email of the user.
  /// [password] represents the password of the user.
  /// [firstName] represents the first name of the user.
  /// [lastName] represents the last name of the user.
  /// [dob] represents the date of birth of the user.
  /// [gender] represents the gender of the user.
  ///
  /// Returns a [UserRegister] objectcontaining the registration information of the user.
  Future<UserRegister> register({
    required String username,
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required DateTime dob,
    required String gender,
  }) async {
    // create a UserRegister object with the necessary fields
    final userRegister = UserRegister(
      username: username,
      password: password,
      firstName: firstName,
      lastName: lastName,
      dob: dob,
      email: email,
      gender: gender,
    );

    await registerUser(userRegister);

    return userRegister;
  }

  /// Fetches the dermatologist associated with the given username.
  ///
  /// Returns a [Dermatologist] object representing the dermatologist.
  /// If the dermatologist is already fetched, returns the existing instance.
  Future<Dermatologist> fetchDermatologist(String username) async {
    if (this.dermatologist != null) return this.dermatologist!;
    final response =
    await _dio.get('$DERMATOLOGISTS_URL/$username/', options: getOptions());
    final dermatologistJson = response.data as Map<String, dynamic>;
    final dermatologist = Dermatologist.fromJson(dermatologistJson);
    this.dermatologist = dermatologist;
    return dermatologist;
  }

  /// Registers a new dermatologist user.
  ///
  /// [username] represents the username of the dermatologist.
  /// [email] represents the email of the dermatologist.
  /// [password] represents the password of the dermatologist.
  /// [firstName] represents the first name of the dermatologist.
  /// [lastName] represents the last name of the dermatologist.
  /// [phoneNumber] represents the phone number of the dermatologist.
  /// [qualification] represents the qualification of the dermatologist.
  /// [clinic] represents the clinic of the dermatologist.
  /// [specialization] represents the specialization of the dermatologist.
  /// [hourlyRate] represents the hourly rate of the dermatologist.
  ///
  /// Returns a [DermUserRegister] object containing the registration information of the dermatologist.
  Future<DermUserRegister> dermRegister({
    required String username,
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String qualification,
    required Clinic clinic,
    required String specialization,
    required double hourlyRate,
  }) async {
    // create a UserRegister object with the necessary fields
    final userRegister = DermUserRegister(
      username: username,
      password: password,
      firstName: firstName,
      lastName: lastName,
      email: email,
      phoneNumber: phoneNumber,
      qualification: qualification,
      clinic: clinic,
      specialization: specialization,
      hourlyRate: hourlyRate,
    );

    await registerDermUser(userRegister);

    return userRegister;
  }
}

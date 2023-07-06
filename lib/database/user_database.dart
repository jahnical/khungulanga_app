import 'dart:async';
import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

//database
const userTable = 'userTable';

/// A class for managing the user database.
class DatabaseProvider {
  static final DatabaseProvider dbProvider = DatabaseProvider();

  Database? _database;

  /// Returns the user database.
  Future <Database> get database async {
    if (_database != null){
      return _database!;
    }
    _database = await createDatabase();
    return _database!;
  }

  /// Creates the user database.
  createDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "User.db");

    var database = await openDatabase(
      path,
      version: 1,
      onCreate: initDB,
      onUpgrade: onUpgrade,
    );
    return database;
  }

  /// Upgrades the user database.
  void onUpgrade(
    Database database,
    int oldVersion,
    int newVersion,
  ){
    if (newVersion > oldVersion){}
  }

  /// Initializes the user database.
  void initDB(Database database, int version) async {
    await database.execute(
      "CREATE TABLE $userTable ("
      "id INTEGER PRIMARY KEY, "
      "username TEXT, "
      "token TEXT "
      ")"
    );
  }
}
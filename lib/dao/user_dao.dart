import 'package:khungulanga_app/database/user_database.dart';
import 'package:khungulanga_app/models/auth_user.dart';

class UserDao {
  final dbProvider = DatabaseProvider.dbProvider;

  Future<int> createUser(AuthUser user) async {
    final db = await dbProvider.database;
    var result = db.insert(userTable, user.toDatabaseJson());
    return result;
  }

  Future<int> deleteUser(int id) async {
    final db = await dbProvider.database;
    var result = await db.delete(userTable, where: "id = ?", whereArgs: [id]);
    return result;
  }

  Future<bool> checkUser(int id) async {
    final db = await dbProvider.database;
    try {
      List<Map> users = await db.query(userTable, where: 'id = ?', whereArgs: [id]);
      return users.isNotEmpty;
    } catch (error) {
      return false;
    }
  }

  Future<AuthUser?> getToken(int id) async {
    //Get token from database
    final db = await dbProvider.database;
    try {
      List<Map<String, dynamic>> users = await db.query(userTable);
      return AuthUser.fromDatabaseJson(users.first);
    } catch (error) {
      return null;
    }
  }
}

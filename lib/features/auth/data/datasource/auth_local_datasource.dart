//chứa code trực tiếp tương tác với sqlite, có nhiệm vụ thực hiện các câu truy vấn

import '../../../../core/database/app_database.dart';
import '../models/user_model.dart';

class AuthLocalDatasource {
  Future<bool> registerUser(UserModel user) async {
    final db = await AppDatabase.database;

    await db.insert('users', user.toMap());
    return true;
  }

  Future<UserModel?> loginUser({
    required String email,
    required String password,
  }) async {
    final db = await AppDatabase.database;

    final result = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );

    if (result.isEmpty) return null;

    return UserModel.fromMap(result.first);
  }

  Future<List<UserModel>> getAllUsers() async {
    final db = await AppDatabase.database;

    final result = await db.query('users');

    return result.map((e) => UserModel.fromMap(e)).toList();
  }

  Future<UserModel?> getCurrentUser() async {
    return null; // implement sau
  }

  Future<void> logout() async {}

  Future<void> updateOnboarding({
    required int userId,
    required String occupation,
    required String financialGoal,
    required String currency,
  }) async {
    final db = await AppDatabase.database;

    await db.update(
      'users',
      {
        'occupation': occupation,
        'financial_goal': financialGoal,
        'currency': currency,
        'onboarding_completed': 1,
      },
      where: 'id = ?',
      whereArgs: [userId],
    );
  }
}

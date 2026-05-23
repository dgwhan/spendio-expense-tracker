import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import '../../../../core/database/app_database.dart';
import '../models/user_model.dart';

/// local authentication datasource
class AuthLocalDatasource {
  /// register new user
  Future<bool> registerUser(
    UserModel user,
  ) async {
    try {
      final Database database =
          await AppDatabase.database;

      await database.insert(
        'users',
        user.toMap(),
      );

      return true;
    } catch (e) {
      return false;
    }
  }

  /// login existing user
  Future<UserModel?> loginUser({
    required String email,
    required String password,
  }) async {
    final Database database =
        await AppDatabase.database;

    final result = await database.query(
      'users',

      where:
          'email = ? AND password = ?',

      whereArgs: [
        email,
        password,
      ],
    );

    if (result.isEmpty) {
      return null;
    }

    final user =
        UserModel.fromMap(result.first);

    final preferences =
        await SharedPreferences
            .getInstance();

    await preferences.setInt(
      'current_user_id',
      user.id!,
    );

    return user;
  }

  /// get current logged user
  Future<UserModel?> getCurrentUser()
      async {
    final preferences =
        await SharedPreferences
            .getInstance();

    final userId = preferences.getInt(
      'current_user_id',
    );

    if (userId == null) {
      return null;
    }

    final Database database =
        await AppDatabase.database;

    final result = await database.query(
      'users',

      where: 'id = ?',

      whereArgs: [userId],
    );

    if (result.isEmpty) {
      return null;
    }

    return UserModel.fromMap(
      result.first,
    );
  }

  /// logout current user
  Future<void> logout() async {
    final preferences =
        await SharedPreferences
            .getInstance();

    await preferences.remove(
      'current_user_id',
    );
  }

  /// update onboarding data
  Future<void> updateOnboarding({
    required int userId,
    required String occupation,
    required String financialGoal,
    required String currency,
  }) async {
    final Database database =
        await AppDatabase.database;

    await database.update(
      'users',
      {
        'occupation': occupation,

        'financial_goal':
            financialGoal,

        'currency': currency,

        'onboarding_completed': 1,
      },

      where: 'id = ?',

      whereArgs: [userId],
    );
  }
}
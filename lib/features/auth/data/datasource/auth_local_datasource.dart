//chứa code trực tiếp tương tác với sqlite, có nhiệm vụ thực hiện các câu truy vấn

import 'package:sqflite/sqflite.dart';
import '../../../../core/database/app_database.dart';
import '../models/user_model.dart';

class AuthLocalDatasource {
  Future<bool> registerUser(UserModel user) async {
    final db = await AppDatabase.database;

    await db.insert(
      'users', 
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
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

  Future<void> updateOnboarding(UserModel user) async {
    final db = await AppDatabase.database;

    await db.update(
      'users',
      {
        'occupation': user.occupation,
        'financial_goal': user.financialGoal,
        'currency_code': user.currency,
        'onboarding_completed': user.onboardingCompleted ? 1 : 0,
      },
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  /// Đồng bộ dữ liệu người dùng và số dư ví từ Firestore về SQLite cục bộ khi đăng nhập
  Future<void> syncUserFromFirebase(UserModel userModel, {double? walletBalance}) async {
    final db = await AppDatabase.database;

    final userResult = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [userModel.email],
      limit: 1,
    );

    int userId;
    if (userResult.isEmpty) {
      userId = await db.insert('users', userModel.toMap());
    } else {
      userId = userResult.first['id'] as int;
      await db.update(
        'users',
        {
          'display_name': userModel.displayName,
          'occupation': userModel.occupation,
          'financial_goal': userModel.financialGoal,
          'currency_code': userModel.currency,
          'onboarding_completed': userModel.onboardingCompleted ? 1 : 0,
          'updated_at': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [userId],
      );
    }

    if (walletBalance != null) {
      final walletResult = await db.query(
        'wallets',
        where: 'user_id = ?',
        whereArgs: [userId],
        limit: 1,
      );

      if (walletResult.isEmpty) {
        await db.insert('wallets', {
          'user_id': userId,
          'wallet_name': 'Main Wallet',
          'balance': walletBalance,
          'currency_code': userModel.currency ?? 'VND',
          'created_at': DateTime.now().toIso8601String(),
        });
      } else {
        await db.update(
          'wallets',
          {
            'balance': walletBalance,
            'currency_code': userModel.currency ?? 'VND',
          },
          where: 'user_id = ?',
          whereArgs: [userId],
        );
      }
    }
  }
}

import 'package:flutter/material.dart';
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
    return null;
  }

  Future<void> logout() async {
    final db = await AppDatabase.database;
    try {
      await db.delete('wallets');
      debugPrint(
          '[Auth Local]: Wiped all cached wallet data on logout to prevent cross-user leakage.');
    } catch (e) {
      debugPrint('[Auth Local] Error while wiping cached session: $e');
    }
  }

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

  Future<void> syncUserFromFirebase(
    UserModel userModel, {
    double? walletBalance,
    String? firestoreWalletId,
  }) async {
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
      final localUserMap = userResult.first;
      userId = localUserMap['id'] as int;

      final String? finalCurrency =
          (userModel.currency != null && userModel.currency!.trim().isNotEmpty)
              ? userModel.currency
              : localUserMap['currency_code'] as String?;

      final int finalOnboardingStatus = (userModel.onboardingCompleted)
          ? 1
          : (localUserMap['onboarding_completed'] as int? ?? 0);

      await db.update(
        'users',
        {
          'display_name': userModel.displayName,
          'occupation': userModel.occupation ?? localUserMap['occupation'],
          'financial_goal':
              userModel.financialGoal ?? localUserMap['financial_goal'],
          'currency_code': finalCurrency,
          'onboarding_completed': finalOnboardingStatus,
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

      final nowStr = DateTime.now().toIso8601String();

      // Read once more from the highly protected user table data above
      final userCheck = await db.query('users',
          columns: ['currency_code'], where: 'id = ?', whereArgs: [userId]);
      final String? verifiedCurrencyCode = userCheck.isNotEmpty
          ? userCheck.first['currency_code'] as String?
          : null;

      // CRITICAL GUARD CLAUSE: If both datasets are empty, kill execution to defend DB integrity
      if (verifiedCurrencyCode == null || verifiedCurrencyCode.trim().isEmpty) {
        debugPrint(
            '[Auth Local Safe Guard]: Aborted default wallet initialization! Reason: Valid currency settings not found for User ID: $userId.');
        return;
      }

      if (walletResult.isEmpty) {
        final walletId =
            (firestoreWalletId != null && firestoreWalletId.trim().isNotEmpty)
                ? firestoreWalletId
                : 'acc_${DateTime.now().millisecondsSinceEpoch}';

        await db.insert('wallets', {
          'id': walletId,
          'user_id': userId,
          'wallet_name': 'Main Wallet',
          'wallet_type': 'cash',
          'balance': walletBalance,
          'currency_code': verifiedCurrencyCode,
          'icon_code_point': Icons.wallet.codePoint,
          'icon_font_family': 'MaterialIcons',
          'created_at': nowStr,
          'updated_at': nowStr,
          'deleted_at': null,
        });
        debugPrint(
            '[Auth Local]: Wallet synchronization completed successfully with currency code: $verifiedCurrencyCode');
      } else {
        await db.update(
          'wallets',
          {
            'balance': walletBalance,
            'currency_code': verifiedCurrencyCode,
            'updated_at': nowStr,
          },
          where: 'user_id = ?',
          whereArgs: [userId],
        );
      }
    }
  }

  Future<void> deleteUserByEmail(String email) async {
    final db = await AppDatabase.database;
    await db.delete(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
  }
}

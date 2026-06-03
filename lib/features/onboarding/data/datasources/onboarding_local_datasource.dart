import 'package:sqflite/sqflite.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/tables/users_table.dart';

import '../models/onboarding_model.dart';

abstract class OnboardingLocalDataSource {
  Future<void> saveOnboarding({
    required String email,
    required OnboardingModel model,
  });

  Future<bool> checkCompleted({
    required String email,
  });

  Future<OnboardingModel?> getOnboarding({
    required String email,
  });
}

class OnboardingLocalDataSourceImpl implements OnboardingLocalDataSource {
  Future<Database> get _db async => await AppDatabase.database;

  @override
  Future<void> saveOnboarding({
    required String email,
    required OnboardingModel model,
  }) async {
    final db = await _db;

    // Cập nhật thông tin User
    await db.update(
      UsersTable.tableName,
      {
        'display_name': model.displayName ?? email.split('@').first,
        'occupation': model.occupation,
        'financial_goal': model.goals.join(','),
        'currency_code': model.currencyCode,
        'onboarding_completed': model.onboardingCompleted ? 1 : 0,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'email = ?',
      whereArgs: [email],
    );

    // Lấy ID của User để liên kết ví
    final userResult = await db.query(
      UsersTable.tableName,
      columns: ['id'],
      where: 'email = ?',
      whereArgs: [email],
      limit: 1,
    );

    if (userResult.isNotEmpty) {
      final userId = userResult.first['id'] as int;

      // Kiểm tra xem ví chính đã tồn tại chưa
      final walletResult = await db.query(
        'wallets',
        where: 'user_id = ?',
        whereArgs: [userId],
        limit: 1,
      );

      if (walletResult.isEmpty) {
        // Tạo ví mới với số dư ban đầu
        await db.insert('wallets', {
          'user_id': userId,
          'wallet_name': 'Main Wallet',
          'balance': model.initialBalance ?? 0.0,
          'currency_code': model.currencyCode ?? 'VND',
          'created_at': DateTime.now().toIso8601String(),
        });
      } else {
        // Cập nhật ví hiện tại
        await db.update(
          'wallets',
          {
            'balance': model.initialBalance ?? 0.0,
            'currency_code': model.currencyCode ?? 'VND',
          },
          where: 'user_id = ?',
          whereArgs: [userId],
        );
      }
    }
  }

  @override
  Future<bool> checkCompleted({
    required String email,
  }) async {
    final db = await _db;

    final result = await db.query(
      UsersTable.tableName,
      where: 'email = ?',
      whereArgs: [email],
      limit: 1,
    );

    if (result.isEmpty) {
      return false;
    }

    return (result.first['onboarding_completed'] as int) == 1;
  }

  @override
  Future<OnboardingModel?> getOnboarding({
    required String email,
  }) async {
    final db = await _db;

    final userResult = await db.query(
      UsersTable.tableName,
      where: 'email = ?',
      whereArgs: [email],
      limit: 1,
    );

    if (userResult.isEmpty) {
      return null;
    }

    final userMap = userResult.first;
    final userId = userMap['id'] as int;

    // Lấy số dư ví (nếu có)
    final walletResult = await db.query(
      'wallets',
      columns: ['balance'],
      where: 'user_id = ?',
      whereArgs: [userId],
      limit: 1,
    );

    double? initialBalance;
    if (walletResult.isNotEmpty) {
      initialBalance = (walletResult.first['balance'] as num?)?.toDouble();
    }

    return OnboardingModel(
      displayName: userMap['display_name'] as String?,
      occupation: userMap['occupation'] as String?,
      goals: userMap['financial_goal'] != null
          ? (userMap['financial_goal'] as String)
              .split(',')
              .where((s) => s.isNotEmpty)
              .toList()
          : [],
      currencyCode: userMap['currency_code'] as String?,
      initialBalance: initialBalance,
      onboardingCompleted: userMap['onboarding_completed'] == 1,
    );
  }
}

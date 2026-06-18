import 'package:flutter/material.dart';
import 'package:spend_io_app/core/database/app_database.dart';
import 'package:spend_io_app/core/database/tables/users_table.dart';
import 'package:spend_io_app/features/onboarding/data/models/onboarding_model.dart';
import 'package:sqflite/sqflite.dart';

abstract class OnboardingLocalDataSource {
  Future<void> saveOnboarding({
    required String email,
    required OnboardingModel model,
    required String walletId,
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
    required String walletId,
  }) async {
    final db = await _db;
    final nowStr = DateTime.now().toIso8601String();

    final bool isFinalStep =
        model.currencyCode != null && model.occupation != null;
    final int finalStatus = (model.onboardingCompleted || isFinalStep) ? 1 : 0;

    await db.update(
      UsersTable.tableName,
      {
        'display_name': model.displayName ?? email.split('@').first,
        'occupation': model.occupation,
        'financial_goal': model.goals.join(','),
        'currency_code': model.currencyCode,
        'onboarding_completed': finalStatus,
        'updated_at': nowStr,
      },
      where: 'email = ?',
      whereArgs: [email],
    );

    debugPrint(
        '[Onboarding Local Guard]: Saved onboarding_completed as $finalStatus into SQLite.');

    final userResult = await db.query(
      UsersTable.tableName,
      columns: ['id'],
      where: 'email = ?',
      whereArgs: [email],
      limit: 1,
    );

    if (userResult.isNotEmpty) {
      final userId = userResult.first['id'] as int;

      final walletResult = await db.query(
        'wallets',
        where: 'user_id = ? AND deleted_at IS NULL',
        whereArgs: [userId],
        limit: 1,
      );

      final String? rawCurrencyCode = model.currencyCode;
      if (rawCurrencyCode == null || rawCurrencyCode.trim().isEmpty) {
        debugPrint(
            '[Onboarding Local Critical]: currencyCode form screen Onboarding is empty!');
        return;
      }

      final String verifiedCurrencyCode = rawCurrencyCode;

      if (walletResult.isEmpty) {
        await db.insert('wallets', {
          'id': walletId,
          'user_id': userId,
          'wallet_name': 'Main Wallet',
          'wallet_type': 'cash',
          'balance': model.initialBalance ?? 0.0,
          'currency_code': verifiedCurrencyCode,
          'icon_code_point': Icons.wallet.codePoint,
          'icon_font_family': 'MaterialIcons',
          'created_at': nowStr,
          'updated_at': nowStr,
        });
        debugPrint(
            '[Onboarding Local]: Fresh user. Initialized default wallet $walletId.');
      } else {
        debugPrint(
            '[Onboarding Local]: Existing user detected. Wallet bypass completed. Handing over to AccountRepository.');
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
  Future<OnboardingModel?> getOnboarding({required String email}) async {
    final db = await _db;

    final userResult = await db.query(
      UsersTable.tableName,
      where: 'email = ?',
      whereArgs: [email],
      limit: 1,
    );

    if (userResult.isEmpty) return null;

    final userMap = userResult.first;
    final userId = userMap['id'] as int;

    final walletResult = await db.query(
      'wallets',
      columns: ['id', 'balance', 'currency_code'],
      where: 'user_id = ? AND deleted_at IS NULL',
      whereArgs: [userId],
      limit: 1,
    );

    double? initialBalance;
    String? walletId;
    String? walletCurrencyCode;

    if (walletResult.isNotEmpty) {
      final walletMap = walletResult.first;
      initialBalance = (walletMap['balance'] as num?)?.toDouble();
      walletId = walletMap['id']?.toString();
      walletCurrencyCode = walletMap['currency_code']?.toString();
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
      currencyCode: walletCurrencyCode ?? (userMap['currency_code'] as String?),
      initialBalance: initialBalance,
      walletId: walletId,
      onboardingCompleted: userMap['onboarding_completed'] == 1,
    );
  }
}

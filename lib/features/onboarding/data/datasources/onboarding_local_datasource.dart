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

    await db.update(
      UsersTable.tableName,
      {
        'display_name': model.displayName,
        'occupation': model.occupation,
        'currency_code': model.currencyCode,
        'onboarding_completed': model.onboardingCompleted ? 1 : 0,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'email = ?',
      whereArgs: [email],
    );
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

    final result = await db.query(
      UsersTable.tableName,
      where: 'email = ?',
      whereArgs: [email],
      limit: 1,
    );

    if (result.isEmpty) {
      return null;
    }

    return OnboardingModel.fromMap(
      result.first,
    );
  }
}

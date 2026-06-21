import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseLogger {
  DatabaseLogger._();

  static Future<void> onOpen(Database db) async {
    debugPrint('');
    debugPrint('========== DATABASE OPEN ==========');

    await _logVersion(db);
    await _logTables(db);

    await _logCount(db, 'categories', 'Categories');
    await _logCount(db, 'transactions', 'Transactions');
    await _logCount(db, 'budgets', 'Budgets');
    await _logCount(
      db,
      'budget_categories',
      'Budget Categories',
    );

    await _logCount(db, 'saving_goals', 'Savings Goals');
    await _logCount(
        db, 'saving_goal_contributions', 'Saving Goal Contributions');

    await _logBudgetSummary(db);
    await _logGoalsSummary(db);

    debugPrint('===================================');
    debugPrint('');
  }

  static Future<void> _logVersion(Database db) async {
    final version = await db.getVersion();

    debugPrint('[DB] Version: $version');
  }

  static Future<void> _logTables(Database db) async {
    final tables = await db.rawQuery(
      '''
      SELECT name
      FROM sqlite_master
      WHERE type = 'table'
      ORDER BY name
      ''',
    );

    debugPrint('[DB] Tables:');

    for (final table in tables) {
      debugPrint('   - ${table['name']}');
    }
  }

  static Future<void> _logCount(
    Database db,
    String tableName,
    String label,
  ) async {
    if (!await _tableExists(db, tableName)) {
      return;
    }

    final result = await db.rawQuery(
      '''
      SELECT COUNT(*) AS total
      FROM $tableName
      ''',
    );

    debugPrint(
      '[DB] $label: ${result.first['total']}',
    );
  }

  static Future<void> _logBudgetSummary(
    Database db,
  ) async {
    if (!await _tableExists(db, 'budgets')) {
      return;
    }

    final result = await db.rawQuery(
      '''
      SELECT
        COUNT(*) AS total,
        COALESCE(SUM(amount), 0) AS total_budget
      FROM budgets
      ''',
    );

    debugPrint(
      '[DB] Budget Summary: '
      '${result.first['total']} budgets'
      ' | Total Budget = ${result.first['total_budget']}',
    );
  }

  static Future<void> _logGoalsSummary(
    Database db,
  ) async {
    if (!await _tableExists(db, 'saving_goals')) {
      return;
    }

    final result = await db.rawQuery(
      '''
      SELECT
        COUNT(*) AS total,
        COUNT(CASE WHEN status = 'active' THEN 1 END) AS active_count,
        COUNT(CASE WHEN status = 'completed' THEN 1 END) AS completed_count,
        COALESCE(SUM(target_amount), 0) AS total_target
      FROM saving_goals
      WHERE deleted_at IS NULL
      ''',
    );

    final row = result.first;
    debugPrint(
      '[DB] Goals Summary: '
      '${row['total']} total (Act: ${row['active_count']} | Comp: ${row['completed_count']})'
      ' | Total Target = ${row['total_target']}',
    );
  }

  static Future<bool> _tableExists(
    Database db,
    String tableName,
  ) async {
    final result = await db.rawQuery(
      '''
      SELECT name
      FROM sqlite_master
      WHERE type = 'table'
        AND name = ?
      ''',
      [tableName],
    );

    return result.isNotEmpty;
  }
}

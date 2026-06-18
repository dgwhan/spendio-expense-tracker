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

    await _logBudgetSummary(db);

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

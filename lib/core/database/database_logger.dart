import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseLogger {
  DatabaseLogger._();

  static Future<void> onOpen(Database db) async {
    debugPrint('');
    debugPrint('========== DATABASE OPEN ==========');

    await _logVersion(db);
    await _logTables(db);
    await _logCategories(db);
    await _logTransactions(db);

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
      WHERE type='table'
      ORDER BY name
      ''',
    );

    debugPrint('[DB] Tables:');

    for (final table in tables) {
      debugPrint('   - ${table['name']}');
    }
  }

  static Future<void> _logCategories(Database db) async {
    try {
      final result = await db.rawQuery(
        '''
        SELECT COUNT(*) AS total
        FROM categories
        ''',
      );

      debugPrint(
        '[DB] Categories: ${result.first['total']}',
      );
    } catch (_) {}
  }

  static Future<void> _logTransactions(Database db) async {
    try {
      final result = await db.rawQuery(
        '''
        SELECT COUNT(*) AS total
        FROM transactions
        ''',
      );

      debugPrint(
        '[DB] Transactions: ${result.first['total']}',
      );
    } catch (_) {}
  }
}

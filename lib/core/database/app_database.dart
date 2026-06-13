import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'migrations/migration_v1.dart';
import 'migrations/migration_v4.dart';
import 'migrations/migration_v5.dart';

/// Application SQLite database
class AppDatabase {
  AppDatabase._();

  static Database? _database;

  /// Singleton database instance
  static Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initializeDatabase();

    return _database!;
  }

  /// Initialize database
  static Future<Database> _initializeDatabase() async {
    final dbPath = await getDatabasesPath();

    final path = join(
      dbPath,
      'spendio.db',
    );

    return openDatabase(
      path,
      version: 5,
      onConfigure: (db) async {
        await db.execute(
          'PRAGMA foreign_keys = ON',
        );
      },
      onCreate: (db, version) async {
        await MigrationV1.run(db);
        await MigrationV4.run(db);
        await MigrationV5.run(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 4) {
          await MigrationV4.run(db);
        }
        if (oldVersion < 5) {
          await MigrationV5.run(db);
        }
      },
      onOpen: (db) async {
        debugPrint('DB opened at: $path');
      },
    );
  }

  /// Close database
  static Future<void> close() async {
    if (_database != null) {
      await _database!.close();

      _database = null;
    }
  }
}

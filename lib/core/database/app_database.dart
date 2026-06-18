import 'package:path/path.dart';
import 'package:spend_io_app/core/database/database_logger.dart';
import 'package:sqflite/sqflite.dart';

import 'migrations/migration_v1.dart';
import 'migrations/migration_v4.dart';
import 'migrations/migration_v5.dart';
import 'migrations/migration_v6.dart';
import 'migrations/migration_v7.dart';
import 'migrations/migration_v8.dart';
import 'migrations/migration_v9.dart';

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
      version: 9,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, version) async {
        await MigrationV1.run(db);
        await MigrationV4.run(db);
        await MigrationV5.run(db);
        await MigrationV6.run(db);
        await MigrationV7.run(db);
        await MigrationV8.run(db);
        await MigrationV9.run(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 4) await MigrationV4.run(db);
        if (oldVersion < 5) await MigrationV5.run(db);
        if (oldVersion < 6) await MigrationV6.run(db);
        if (oldVersion < 7) await MigrationV7.run(db);
        if (oldVersion < 8) await MigrationV8.run(db);
        if (oldVersion < 9) {
          await MigrationV9.run(db);
        }
      },
      onOpen: (db) async {
        await DatabaseLogger.onOpen(db);
      },
    );
  }

  /// Close database
  static Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null; // Reset về null để giải phóng RAM hoàn toàn
    }
  }
}

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
import 'migrations/migration_v10.dart';

class AppDatabase {
  AppDatabase._();

  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initializeDatabase();
    return _database!;
  }

  static Future<Database> _initializeDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'spendio.db');

    return openDatabase(
      path,
      version: 11,
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
        await MigrationV10.run(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 4) await MigrationV4.run(db);
        if (oldVersion < 5) await MigrationV5.run(db);
        if (oldVersion < 6) await MigrationV6.run(db);
        if (oldVersion < 7) await MigrationV7.run(db);
        if (oldVersion < 8) await MigrationV8.run(db);
        if (oldVersion < 9) await MigrationV9.run(db);
        if (oldVersion < 10) await MigrationV10.run(db);
      },
      onOpen: (db) async {
        await DatabaseLogger.onOpen(db);
      },
    );
  }

  static Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }

  

  static Database get databaseInstance {
    if (_database == null) {
      throw StateError(
          'Database chưa được khởi tạo! Hãy đảm bảo đã await ở SplashScreen.');
    }
    return _database!;
  }
}

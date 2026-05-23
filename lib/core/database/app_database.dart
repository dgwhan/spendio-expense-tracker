import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// application sqlite database
class AppDatabase {
  static Database? _database;

  /// singleton database instance
  static Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initializeDatabase();

    return _database!;
  }

  /// initialize sqlite database
  static Future<Database> _initializeDatabase() async {
    
    const path = 'spendio.db';

    return openDatabase(
      path,
      version: 2,

      onCreate: _onCreate,
    );
  }

  /// create database tables
  static Future<void> _onCreate(
    Database db,
    int version,
  ) async {
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,

        email TEXT UNIQUE,
        password TEXT,

        display_name TEXT,
        full_name TEXT,

        occupation TEXT,
        financial_goal TEXT,
        currency TEXT,

        onboarding_completed INTEGER,

        created_at TEXT
      )
    ''');
  }
}
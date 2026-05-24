import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

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

  /// Initialize database with correct device storage path
  static Future<Database> _initializeDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'spendio.db'); 

    return openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onOpen: (db) async {
        // debug hook
        print('DB opened at: $path');
      },
    );
  }

  /// Create initial tables
  static Future<void> _onCreate(Database db, int version) async {
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
        onboarding_completed INTEGER DEFAULT 0,
        created_at TEXT
      )
    ''');
  }

  /// Handle schema migrations 
  static Future<void> _onUpgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion < 2) {
      // example migration (safe expansion)
      // await db.execute('ALTER TABLE users ADD COLUMN avatar TEXT');
    }
  }

  /// Close database (optional cleanup)
  static Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
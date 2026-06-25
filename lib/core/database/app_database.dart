import 'package:path/path.dart';
import 'package:spend_io_app/core/database/database_logger.dart';
import 'package:spend_io_app/core/database/tables/budget_categories_table.dart';
import 'package:spend_io_app/core/database/tables/budgets_table.dart';
import 'package:spend_io_app/core/database/tables/categories_table.dart';
import 'package:spend_io_app/core/database/tables/saving_goal_contributions_table.dart';
import 'package:spend_io_app/core/database/tables/saving_goals_table.dart';
import 'package:spend_io_app/core/database/tables/transactions_table.dart';
import 'package:spend_io_app/core/database/tables/users_table.dart';
import 'package:spend_io_app/core/database/tables/wallets_table.dart';
import 'package:spend_io_app/core/utils/app_default_categories.dart';
import 'package:sqflite/sqflite.dart';

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
      version: 1,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, version) async {
        // Create tables
        await db.execute(UsersTable.createTable);
        await db.execute(WalletsTable.createTable);
        await db.execute(CategoriesTable.createTable);
        await db.execute(TransactionsTable.createTable);
        await db.execute(BudgetsTable.createTable);
        await db.execute(BudgetCategoriesTable.createTable);
        await db.execute(SavingGoalsTable.createTable);
        await db.execute(SavingGoalContributionsTable.createTable);

        // Create indexes
        for (final index in BudgetsTable.createIndexes) {
          await db.execute(index);
        }
        for (final index in BudgetCategoriesTable.createIndexes) {
          await db.execute(index);
        }
        for (final index in SavingGoalsTable.createIndexes) {
          await db.execute(index);
        }
        for (final index in SavingGoalContributionsTable.createIndexes) {
          await db.execute(index);
        }

        // Seed default categories
        final now = DateTime.now().toIso8601String();
        final batch = db.batch();

        for (final category in AppDefaultCategories.rawSeedData) {
          batch.insert(CategoriesTable.tableName, {
            ...category,
            'user_id': 0,
            'icon_font_family': 'MaterialIcons',
            'created_at': now,
            'updated_at': now,
          });
        }
        await batch.commit(noResult: true);
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
          'Database chưa được khởi tạo! Đảm bảo đã await ở SplashScreen.');
    }
    return _database!;
  }
}

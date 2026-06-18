import 'package:spend_io_app/core/database/app_database.dart';
import 'package:spend_io_app/features/budget/data/models/budget_model.dart';
import 'package:spend_io_app/features/budget/data/models/budget_category_model.dart';
import 'package:sqflite/sqflite.dart';

abstract class BudgetLocalDataSource {
  Future<BudgetModel?> getCurrentBudget(int userId);
  Future<void> createBudget(BudgetModel budget);
  Future<void> updateBudget(BudgetModel budget);
  Future<void> deleteBudget(String budgetId);

  Future<List<BudgetCategoryModel>> getBudgetCategories(String budgetId);
  Future<void> createBudgetCategory(BudgetCategoryModel category);
  Future<void> updateBudgetCategory(BudgetCategoryModel category);
  Future<void> deleteBudgetCategory(String id);

  Future<bool> hasCategories(int userId);
}

class BudgetLocalDataSourceImpl implements BudgetLocalDataSource {
  Future<Database> get _db => AppDatabase.database;

  BudgetLocalDataSourceImpl();

  @override
  Future<BudgetModel?> getCurrentBudget(int userId) async {
    final db = await _db;
    final maps = await db.query(
      'budgets',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'start_date DESC',
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return BudgetModel.fromMap(maps.first);
  }

  @override
  Future<void> createBudget(BudgetModel budget) async {
    final db = await _db;
    await db.insert(
      'budgets',
      budget.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> updateBudget(BudgetModel budget) async {
    final db = await _db;
    await db.update(
      'budgets',
      budget.toMap(),
      where: 'id = ?',
      whereArgs: [budget.id],
    );
  }

  @override
  Future<void> deleteBudget(String budgetId) async {
    final db = await _db;
    await db.transaction((txn) async {
      await txn.delete(
        'budget_categories',
        where: 'budget_id = ?',
        whereArgs: [budgetId],
      );
      await txn.delete(
        'budgets',
        where: 'id = ?',
        whereArgs: [budgetId],
      );
    });
  }

  @override
  Future<List<BudgetCategoryModel>> getBudgetCategories(String budgetId) async {
    final db = await _db;
    final maps = await db.query(
      'budget_categories',
      where: 'budget_id = ?',
      whereArgs: [budgetId],
    );
    return maps.map((map) => BudgetCategoryModel.fromMap(map)).toList();
  }

  @override
  Future<void> createBudgetCategory(BudgetCategoryModel category) async {
    final db = await _db;
    await db.insert(
      'budget_categories',
      category.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> updateBudgetCategory(BudgetCategoryModel category) async {
    final db = await _db;
    await db.update(
      'budget_categories',
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  @override
  Future<void> deleteBudgetCategory(String id) async {
    final db = await _db;
    await db.delete(
      'budget_categories',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<bool> hasCategories(int userId) async {
    final db = await _db;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM budgets WHERE user_id = ?',
      [userId],
    );

    if (result.isEmpty) return false;
    final count = Sqflite.firstIntValue(result) ?? 0;
    return count > 0;
  }
}

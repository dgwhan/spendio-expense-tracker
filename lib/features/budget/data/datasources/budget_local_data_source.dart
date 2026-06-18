import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:spend_io_app/features/budget/data/models/budget_model.dart';
import 'package:spend_io_app/features/budget/data/models/budget_category_model.dart';

abstract class BudgetLocalDataSource {
  Future<BudgetModel?> getCurrentBudget(int userId);

  Future<void> createBudget(BudgetModel budget);

  Future<void> updateBudget(BudgetModel budget);

  Future<void> deleteBudget(String budgetId);

  Future<List<BudgetCategoryModel>> getBudgetCategories({
    required int userId,
  });

  Future<List<BudgetCategoryModel>> getBudgetCategoriesByPeriod({
    required int userId,
    required DateTime date,
  });

  Future<void> createBudgetCategory(BudgetCategoryModel category);

  Future<void> updateBudgetCategory(BudgetCategoryModel category);

  Future<void> deleteBudgetCategory(String id);

  Future<bool> hasBudgetCategories(int userId);
}

class BudgetLocalDataSourceImpl implements BudgetLocalDataSource {
  final Database database;

  BudgetLocalDataSourceImpl(this.database) {
    if (!database.isOpen) {
      debugPrint(
          '[DI CRITICAL ERROR]: Database passed to BudgetLocalDataSource is CLOSED!');
    }
  }

  @override
  Future<BudgetModel?> getCurrentBudget(int userId) async {
    final result = await database.query(
      'budgets',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'start_date DESC',
      limit: 1,
    );

    if (result.isEmpty) {
      debugPrint(
          '[DATA MISMATCH NOTICE]: No budget found in table "budgets" for User ID: $userId');
      return null;
    }

    return BudgetModel.fromMap(result.first);
  }

  @override
  Future<void> createBudget(BudgetModel budget) async {
    await database.insert(
      'budgets',
      budget.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    debugPrint(
        '[DB INSERT]: Saved budget ${budget.id} for User ID: ${budget.userId}');
  }

  @override
  Future<void> updateBudget(BudgetModel budget) async {
    final count = await database.update(
      'budgets',
      budget.toMap(),
      where: 'id = ?',
      whereArgs: [budget.id],
    );
    if (count == 0) {
      debugPrint(
          '[DATA MISMATCH ERROR]: Cannot update budget. ID ${budget.id} not found.');
    }
  }

  @override
  Future<void> deleteBudget(String budgetId) async {
    final count = await database.delete(
      'budgets',
      where: 'id = ?',
      whereArgs: [budgetId],
    );
    if (count == 0) {
      debugPrint(
          '[DATA MISMATCH ERROR]: Cannot delete budget. ID $budgetId not found.');
    }
  }

  @override
  Future<List<BudgetCategoryModel>> getBudgetCategories({
    required int userId,
  }) async {
    final result = await database.query(
      'budget_categories',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );

    if (result.isEmpty) {
      debugPrint(
          '[DATA MISMATCH NOTICE]: No records found in "budget_categories" for User ID: $userId');
    } else {
      debugPrint(
          '[DB QUERY]: Fetched ${result.length} items from "budget_categories" for User ID: $userId');
    }

    return result.map(BudgetCategoryModel.fromMap).toList();
  }

  @override
  Future<List<BudgetCategoryModel>> getBudgetCategoriesByPeriod({
    required int userId,
    required DateTime date,
  }) async {
    final dateIso = date.toIso8601String();
    final result = await database.query(
      'budget_categories',
      where: 'user_id = ? AND start_date <= ? AND end_date >= ?',
      whereArgs: [userId, dateIso, dateIso],
    );

    if (result.isEmpty) {
      debugPrint(
          '[DATA MISMATCH NOTICE]: No active category budget found for User ID: $userId at date: $dateIso');
    } else {
      debugPrint(
          '[DB QUERY]: Found ${result.length} active category budgets for date: $dateIso');
    }

    return result.map(BudgetCategoryModel.fromMap).toList();
  }

  @override
  Future<void> createBudgetCategory(BudgetCategoryModel category) async {
    await database.insert(
      'budget_categories',
      category.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    debugPrint(
        '[DB INSERT]: Saved budget category ${category.id} for User ID: ${category.userId}');
  }

  @override
  Future<void> updateBudgetCategory(BudgetCategoryModel category) async {
    final count = await database.update(
      'budget_categories',
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
    if (count == 0) {
      debugPrint(
          '[DATA MISMATCH ERROR]: Cannot update budget category. ID ${category.id} not found.');
    }
  }

  @override
  Future<void> deleteBudgetCategory(String id) async {
    final count = await database.delete(
      'budget_categories',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (count == 0) {
      debugPrint(
          '[DATA MISMATCH ERROR]: Cannot delete budget category. ID $id not found.');
    }
  }

  @override
  Future<bool> hasBudgetCategories(int userId) async {
    final result = await database.rawQuery(
      'SELECT COUNT(*) count FROM budget_categories WHERE user_id = ?',
      [userId],
    );

    final count = Sqflite.firstIntValue(result) ?? 0;
    debugPrint('[DB CHECK]: User ID: $userId has $count budget categories.');
    return count > 0;
  }
}

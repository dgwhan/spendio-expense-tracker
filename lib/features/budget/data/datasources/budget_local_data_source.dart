import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:spend_io_app/features/budget/data/models/budget_model.dart';
import 'package:spend_io_app/features/budget/data/models/budget_category_model.dart';

abstract class BudgetLocalDataSource {
  Future<BudgetModel?> getCurrentBudget(int userId);
  Future<void> createBudget(BudgetModel budget);
  Future<void> updateBudget(BudgetModel budget);
  Future<void> deleteBudget(String budgetId);
  Future<List<BudgetCategoryModel>> getBudgetCategories({required int userId});
  Future<List<BudgetCategoryModel>> getBudgetCategoriesByPeriod(
      {required int userId, required DateTime date});
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
          '[💡 SQLITE FETCH NOTICE]: Không tìm thấy budget nào cho User ID: $userId');
      return null;
    }

    final budget = BudgetModel.fromMap(result.first);
    debugPrint(
        '[✅ SQLITE FETCH SUCCESS]: Đã tải thành công ngân sách [${budget.name}] - Số tiền: \$${budget.amount} từ SQLite lên RAM.');
    return budget;
  }

  @override
  Future<void> createBudget(BudgetModel budget) async {
    await database.insert(
      'budgets',
      budget.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    // 🌟 LOG THEO DÕI INSERT BUDGET
    debugPrint('------------------------------------------------------------');
    debugPrint('[📥 SQLITE BUDGET INSERTED]: Ghi dữ liệu LOCAL thành công!');
    debugPrint('  ❖ ID: ${budget.id}');
    debugPrint('  ❖ User ID: ${budget.userId}');
    debugPrint('  ❖ Name: ${budget.name}');
    debugPrint('  ❖ Amount: \$${budget.amount}');
    debugPrint('------------------------------------------------------------');
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
          '[❌ SQLITE UPDATE ERROR]: Không tìm thấy Budget ID ${budget.id} để cập nhật.');
    } else {
      debugPrint(
          '[✏️ SQLITE BUDGET UPDATED]: Cập nhật thành công Budget [${budget.name}] ở Local SQLite.');
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
          '[❌ SQLITE DELETE ERROR]: Thất bại! Không tìm thấy Budget ID $budgetId để xóa.');
    } else {
      debugPrint(
          '[🗑️ SQLITE BUDGET DELETED]: Đã xóa sạch Budget ID $budgetId khỏi SQLite.');
    }
  }

  @override
  Future<List<BudgetCategoryModel>> getBudgetCategories(
      {required int userId}) async {
    final result = await database.query(
      'budget_categories',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );
    debugPrint(
        '[🔍 SQLITE QUERY]: Đã nạp ${result.length} ngân sách danh mục con từ SQLite cho User $userId.');
    return result.map(BudgetCategoryModel.fromMap).toList();
  }

  @override
  Future<List<BudgetCategoryModel>> getBudgetCategoriesByPeriod(
      {required int userId, required DateTime date}) async {
    final dateIso = date.toIso8601String();
    final result = await database.query(
      'budget_categories',
      where: 'user_id = ? AND start_date <= ? AND end_date >= ?',
      whereArgs: [userId, dateIso, dateIso],
    );
    debugPrint(
        '[🔍 SQLITE QUERY PERIOD]: Tìm thấy ${result.length} mục ngân sách con hoạt động trong chu kỳ $dateIso.');
    return result.map(BudgetCategoryModel.fromMap).toList();
  }

  @override
  Future<void> createBudgetCategory(BudgetCategoryModel category) async {
    await database.insert(
      'budget_categories',
      category.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    // 🌟 LOG THEO DÕI INSERT BUDGET CATEGORY
    debugPrint('------------------------------------------------------------');
    debugPrint(
        '[📥 SQLITE CATEGORY INSERTED]: Ghi danh mục ngân sách LOCAL thành công!');
    debugPrint('  ❖ Sub-ID: ${category.id}');
    debugPrint('  ❖ Category ID gốc: ${category.categoryId}');
    debugPrint('  ❖ Hạn mức danh mục: \$${category.amount}');
    debugPrint('------------------------------------------------------------');
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
          '[❌ SQLITE CATEGORY UPDATE ERROR]: Không tìm thấy danh mục ngân sách con ${category.id} để cập nhật.');
    } else {
      debugPrint(
          '[✏️ SQLITE CATEGORY UPDATED]: Cập nhật thành công hạn mức danh mục [${category.categoryId}] ở Local.');
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
          '[❌ SQLITE CATEGORY DELETE ERROR]: Không tìm thấy danh mục ${id} để xóa.');
    } else {
      debugPrint(
          '[🗑️ SQLITE CATEGORY DELETED]: Đã xóa danh mục ngân sách con $id khỏi SQLite.');
    }
  }

  @override
  Future<bool> hasBudgetCategories(int userId) async {
    final result = await database.rawQuery(
      'SELECT COUNT(*) count FROM budget_categories WHERE user_id = ?',
      [userId],
    );
    final count = Sqflite.firstIntValue(result) ?? 0;
    return count > 0;
  }
}

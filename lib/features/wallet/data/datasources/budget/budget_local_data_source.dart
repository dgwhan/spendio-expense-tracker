import 'package:sqflite/sqflite.dart';
import '../../../../../core/database/app_database.dart';
import '../../models/budget_category_model.dart';

abstract class BudgetLocalDataSource {
  Future<List<BudgetCategoryModel>> getCategories(int userId);
  Future<void> insertCategory(int userId, BudgetCategoryModel category);
  Future<void> updateCategory(int userId, BudgetCategoryModel category);
  Future<bool> hasCategories(int userId);
}

class BudgetLocalDataSourceImpl implements BudgetLocalDataSource {
  Future<Database> get _db async => await AppDatabase.database;

  @override
  Future<List<BudgetCategoryModel>> getCategories(int userId) async {
    final db = await _db;
    final result = await db.query(
      'budget_categories',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at ASC',
    );
    return result.map((map) => BudgetCategoryModel.fromMap(map)).toList();
  }

  @override
  Future<void> insertCategory(int userId, BudgetCategoryModel category) async {
    final db = await _db;
    final map = category.toMap();
    map['user_id'] = userId;
    await db.insert(
      'budget_categories',
      map,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> updateCategory(int userId, BudgetCategoryModel category) async {
    final db = await _db;
    final map = category.toMap();
    map['user_id'] = userId;
    await db.update(
      'budget_categories',
      map,
      where: 'id = ? AND user_id = ?',
      whereArgs: [category.id, userId],
    );
  }

  @override
  Future<bool> hasCategories(int userId) async {
    final db = await _db;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM budget_categories WHERE user_id = ?',
      [userId],
    );
    final count = Sqflite.firstIntValue(result) ?? 0;
    return count > 0;
  }
}

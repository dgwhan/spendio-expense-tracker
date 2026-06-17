import 'package:spend_io_app/core/database/tables/categories_table.dart';
import 'package:sqflite/sqflite.dart';
import '../models/category_model.dart';

abstract class CategoryLocalDataSource {
  Future<List<CategoryModel>> getAllCategories();

  Future<List<CategoryModel>> getCategories(int localUserId);

  Future<void> insertCategory(CategoryModel category);

  Future<void> deleteCategory(String categoryId);
}

class CategoryLocalDataSourceImpl implements CategoryLocalDataSource {
  final Future<Database> database;

  CategoryLocalDataSourceImpl({required this.database});

  @override
  Future<List<CategoryModel>> getAllCategories() async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query(
      CategoriesTable.tableName,
    );

    return maps.map((map) => CategoryModel.fromMap(map)).toList();
  }

  @override
  Future<List<CategoryModel>> getCategories(int localUserId) async {
    final db = await database;

    // Select entries where user_id is 0 (global) OR matches the logged-in user
    final List<Map<String, dynamic>> maps = await db.query(
      CategoriesTable.tableName,
      where: 'user_id = 0 OR user_id = ?',
      whereArgs: [localUserId],
    );

    return maps.map((map) => CategoryModel.fromMap(map)).toList();
  }

  @override
  Future<void> insertCategory(CategoryModel category) async {
    final db = await database;
    await db.insert(
      CategoriesTable.tableName,
      category.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> deleteCategory(String categoryId) async {
    final db = await database;

    // Data Integrity Check: Verify if any transaction is bound to this specific id
    final List<Map<String, dynamic>> countResult = await db.rawQuery(
      'SELECT COUNT(*) as total FROM transactions WHERE category_id = ?',
      [categoryId],
    );
    final int transactionCount = countResult.first['total'] as int? ?? 0;

    // Business Rule: Throw exception if database records are dependency locked
    if (transactionCount > 0) {
      throw Exception(
          'Cannot delete category. Active transactions are linked to it.');
    }

    await db.delete(
      CategoriesTable.tableName,
      where: 'id = ?',
      whereArgs: [categoryId],
    );
  }
}

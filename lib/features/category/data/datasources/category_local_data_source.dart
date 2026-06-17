import 'package:sqflite/sqflite.dart';
import '../models/category_model.dart';
import '../../../../core/database/tables/categories_table.dart';

abstract class CategoryLocalDataSource {
  Future<List<CategoryModel>> getCategories(int localUserId);

  Future<void> insertCategory(CategoryModel category);

  Future<void> deleteCategory(String categoryId);
}

class CategoryLocalDataSourceImpl implements CategoryLocalDataSource {
  final Future<Database> database;

  CategoryLocalDataSourceImpl({required this.database});

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

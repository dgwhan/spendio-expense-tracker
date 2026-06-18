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
  // ✅ ĐÃ SỬA: Chuyển từ Future<Database> sang kiểu Database đồng bộ sạch
  final Database database;

  CategoryLocalDataSourceImpl({required this.database});

  @override
  Future<List<CategoryModel>> getAllCategories() async {
    // ✅ ĐÃ TỐI ƯU: Gọi trực tiếp vào database vật lý, không cần tốn nhịp await lấy db nữa
    final List<Map<String, dynamic>> maps = await database.query(
      CategoriesTable.tableName,
    );

    return maps.map((map) => CategoryModel.fromMap(map)).toList();
  }

  @override
  Future<List<CategoryModel>> getCategories(int localUserId) async {
    // Select entries where user_id is 0 (global) OR matches the logged-in user
    final List<Map<String, dynamic>> maps = await database.query(
      CategoriesTable.tableName,
      where: 'user_id = 0 OR user_id = ?',
      whereArgs: [localUserId],
    );

    return maps.map((map) => CategoryModel.fromMap(map)).toList();
  }

  @override
  Future<void> insertCategory(CategoryModel category) async {
    await database.insert(
      CategoriesTable.tableName,
      category.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> deleteCategory(String categoryId) async {
    // Data Integrity Check: Verify if any transaction is bound to this specific id
    final List<Map<String, dynamic>> countResult = await database.rawQuery(
      'SELECT COUNT(*) as total FROM transactions WHERE category_id = ?',
      [categoryId],
    );
    final int transactionCount = countResult.first['total'] as int? ?? 0;

    // Business Rule: Throw exception if database records are dependency locked
    if (transactionCount > 0) {
      throw Exception(
          'Cannot delete category. Active transactions are linked to it.');
    }

    await database.delete(
      CategoriesTable.tableName,
      where: 'id = ?',
      whereArgs: [categoryId],
    );
  }
}

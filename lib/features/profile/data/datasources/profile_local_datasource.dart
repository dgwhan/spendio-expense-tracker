import 'package:spend_io_app/core/database/app_database.dart';
import 'package:spend_io_app/features/auth/data/models/user_model.dart';
import 'package:sqflite/sqflite.dart';

abstract class ProfileLocalDataSource {
  Future<UserModel?> getUserById(int userId);
}

class ProfileLocalDataSourceImpl implements ProfileLocalDataSource {
  // Sử dụng chuẩn Getter Lazy Load giống module Budget
  Future<Database> get _db async => await AppDatabase.database;

  @override
  Future<UserModel?> getUserById(int userId) async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [userId],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return UserModel.fromMap(maps.first);
  }
}

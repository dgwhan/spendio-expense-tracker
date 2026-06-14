import 'package:sqflite/sqflite.dart';
import '../../../../../core/database/app_database.dart';
import '../../models/saving_goal_model.dart';

abstract class GoalLocalDataSource {
  Future<List<SavingGoalModel>> getGoals(int userId);
  Future<void> saveGoal(int userId, SavingGoalModel goal);
  Future<void> deleteGoal(String goalId);
  Future<bool> hasGoals(int userId);
}

class GoalLocalDataSourceImpl implements GoalLocalDataSource {
  Future<Database> get _db async => await AppDatabase.database;

  @override
  Future<List<SavingGoalModel>> getGoals(int userId) async {
    final db = await _db;
    final result = await db.query(
      'financial_goals',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );
    return result.map((map) => SavingGoalModel.fromMap(map)).toList();
  }

  @override
  Future<void> saveGoal(int userId, SavingGoalModel goal) async {
    final db = await _db;
    final map = goal.toMap();
    map['user_id'] = userId;
    await db.insert(
      'financial_goals',
      map,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> deleteGoal(String goalId) async {
    final db = await _db;
    await db.delete(
      'financial_goals',
      where: 'id = ?',
      whereArgs: [goalId],
    );
  }

  @override
  Future<bool> hasGoals(int userId) async {
    final db = await _db;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM financial_goals WHERE user_id = ?',
      [userId],
    );
    final count = Sqflite.firstIntValue(result) ?? 0;
    return count > 0;
  }
}

import 'package:spend_io_app/features/goal/data/models/goal_contribution_model.dart';
import 'package:spend_io_app/features/goal/data/models/goal_model.dart';
import 'package:sqflite/sqflite.dart';

abstract class GoalLocalDataSource {
  Future<List<GoalModel>> getGoals(int userId);

  Future<GoalModel?> getGoalById(String goalId);

  Future<void> insertGoal(GoalModel goal);

  Future<void> updateGoal(GoalModel goal);

  Future<void> deleteGoal(String goalId);

  Future<void> insertContribution(GoalContributionModel contribution);

  Future<List<GoalContributionModel>> getContributions(String goalId);
}

class GoalLocalDataSourceImpl implements GoalLocalDataSource {
  final Database db;

  GoalLocalDataSourceImpl(this.db);

  @override
  Future<List<GoalModel>> getGoals(int userId) async {
    final result = await db.query(
      'goals',
      where: 'user_id = ? AND deleted_at IS NULL',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );

    return result.map(GoalModel.fromMap).toList();
  }

  @override
  Future<GoalModel?> getGoalById(String goalId) async {
    final result = await db.query(
      'goals',
      where: 'id = ? AND deleted_at IS NULL',
      whereArgs: [goalId],
      limit: 1,
    );

    if (result.isEmpty) return null;
    return GoalModel.fromMap(result.first);
  }

  @override
  Future<void> insertGoal(GoalModel goal) async {
    await db.insert('goals', goal.toMap());
  }

  @override
  Future<void> updateGoal(GoalModel goal) async {
    await db.update(
      'goals',
      goal.toMap(),
      where: 'id = ?',
      whereArgs: [goal.id],
    );
  }

  @override
  Future<void> deleteGoal(String goalId) async {
    await db.update(
      'goals',
      {
        'deleted_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [goalId],
    );
  }

  @override
  Future<void> insertContribution(
    GoalContributionModel contribution,
  ) async {
    await db.insert(
      'goal_contributions',
      contribution.toMap(),
    );
  }

  @override
  Future<List<GoalContributionModel>> getContributions(
    String goalId,
  ) async {
    final result = await db.query(
      'goal_contributions',
      where: 'goal_id = ? AND deleted_at IS NULL',
      whereArgs: [goalId],
      orderBy: 'created_at DESC',
    );

    return result.map(GoalContributionModel.fromMap).toList();
  }
}

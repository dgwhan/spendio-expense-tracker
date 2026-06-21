import 'package:spend_io_app/features/saving_goal/data/models/saving_goal_contribution_model.dart';
import 'package:spend_io_app/features/saving_goal/data/models/saving_goal_model.dart';
import 'package:sqflite/sqflite.dart';

abstract class SavingGoalLocalDatasource {
  Future<List<SavingGoalModel>> getGoals(int userId);

  Future<SavingGoalModel?> getGoalById(String goalId);

  Future<void> insertGoal(SavingGoalModel goal);

  Future<void> updateGoal(SavingGoalModel goal);

  Future<void> deleteGoal(String goalId);

  Future<void> insertContribution(GoalContributionModel contribution);

  Future<List<GoalContributionModel>> getContributions(String goalId);
}

class SavingGoalLocalDataSourceImpl implements SavingGoalLocalDatasource {
  final Database db;

  SavingGoalLocalDataSourceImpl(this.db);

  @override
  Future<List<SavingGoalModel>> getGoals(int userId) async {
    final result = await db.query(
      'saving_goals',
      where: 'user_id = ? AND deleted_at IS NULL',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );

    return result.map(SavingGoalModel.fromMap).toList();
  }

  @override
  Future<SavingGoalModel?> getGoalById(String goalId) async {
    final result = await db.query(
      'saving_goals',
      where: 'id = ? AND deleted_at IS NULL',
      whereArgs: [goalId],
      limit: 1,
    );

    if (result.isEmpty) return null;
    return SavingGoalModel.fromMap(result.first);
  }

  @override
  Future<void> insertGoal(SavingGoalModel goal) async {
    await db.insert('saving_goals', goal.toMap());
  }

  @override
  Future<void> updateGoal(SavingGoalModel goal) async {
    await db.update(
      'saving_goals',
      goal.toMap(),
      where: 'id = ?',
      whereArgs: [goal.id],
    );
  }

  @override
  Future<void> deleteGoal(String goalId) async {
    await db.update(
      'saving_goals',
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
      'saving_goal_contributions',
      contribution.toMap(),
    );
  }

  @override
  Future<List<GoalContributionModel>> getContributions(
    String goalId,
  ) async {
    final result = await db.query(
      'saving_goal_contributions',
      where: 'goal_id = ? AND deleted_at IS NULL',
      whereArgs: [goalId],
      orderBy: 'created_at DESC',
    );

    return result.map(GoalContributionModel.fromMap).toList();
  }
}

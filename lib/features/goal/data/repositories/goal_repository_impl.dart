import 'package:spend_io_app/features/goal/data/datasource/goal_local_datasource.dart';
import 'package:spend_io_app/features/goal/data/models/goal_contribution_model.dart';
import 'package:spend_io_app/features/goal/data/models/goal_model.dart';
import 'package:spend_io_app/features/goal/domain/entities/goal_contribution_entity.dart';
import 'package:spend_io_app/features/goal/domain/entities/goal_entity.dart';
import 'package:spend_io_app/features/goal/domain/repositories/goal_repository.dart';
import 'package:sqflite/sqflite.dart';

class GoalRepositoryImpl implements GoalRepository {
  final GoalLocalDataSource local;
  final Database db;

  GoalRepositoryImpl({
    required this.local,
    required this.db,
  });

  // =========================================================
  // CACHE ENGINE (CORE FINTECH LOGIC)
  // =========================================================

  Future<void> _updateGoalCache(String goalId) async {
    final sumResult = await db.rawQuery('''
      SELECT COALESCE(SUM(amount), 0) AS total
      FROM goal_contributions
      WHERE goal_id = ? AND deleted_at IS NULL
    ''', [goalId]);

    final totalContribution = (sumResult.first['total'] as num).toDouble();

    final goalResult = await db.rawQuery('''
      SELECT target_amount, initial_amount, status
      FROM goals
      WHERE id = ?
    ''', [goalId]);

    if (goalResult.isEmpty) return;

    final target = (goalResult.first['target_amount'] as num).toDouble();

    final initial = (goalResult.first['initial_amount'] as num).toDouble();

    final currentStatus = goalResult.first['status'] as String;

    final currentAmount = initial + totalContribution;

    final progress = target <= 0 ? 0.0 : currentAmount / target;

    final clampedProgress = progress > 1.0 ? 1.0 : progress;

    String updatedStatus = currentStatus;

    if (currentStatus != 'archived') {
      updatedStatus = currentAmount >= target ? 'completed' : 'active';
    }

    await db.update(
      'goals',
      {
        'cached_current_amount': currentAmount,
        'cached_progress': clampedProgress,
        'status': updatedStatus,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [goalId],
    );
  }

  // =========================================================
  // GET GOALS
  // =========================================================

  @override
  Future<List<GoalEntity>> getGoals(int userId) async {
    final models = await local.getGoals(userId);
    return models.map((e) => e.toEntity()).toList();
  }

  // =========================================================
  // GET GOAL DETAIL
  // =========================================================

  @override
  Future<GoalEntity?> getGoalById(String goalId) async {
    final model = await local.getGoalById(goalId);
    return model?.toEntity();
  }

  // =========================================================
  // CREATE GOAL
  // =========================================================

  @override
  Future<void> createGoal(GoalEntity goal) async {
    final model = GoalModel.fromEntity(goal);
    await local.insertGoal(model);
  }

  // =========================================================
  // UPDATE GOAL
  // =========================================================

  @override
  Future<void> updateGoal(GoalEntity goal) async {
    final model = GoalModel.fromEntity(goal);

    await local.updateGoal(model);
    await _updateGoalCache(goal.id);
  }

  // =========================================================
  // DELETE GOAL (SOFT DELETE INSIDE LOCAL)
  // =========================================================

  @override
  Future<void> deleteGoal({
    required String goalId,
    required int userId,
  }) async {
    await local.deleteGoal(goalId);
  }

  // =========================================================
  // ADD CONTRIBUTION (CORE FLOW)
  // =========================================================

  @override
  Future<void> addContribution(
    GoalContributionEntity contribution,
  ) async {
    final model = GoalContributionModel.fromEntity(contribution);

    await db.transaction((txn) async {
      await txn.insert(
        'goal_contributions',
        model.toMap(),
      );

      await _updateGoalCache(contribution.goalId);
    });
  }

  // =========================================================
  // GET CONTRIBUTIONS
  // =========================================================

  @override
  Future<List<GoalContributionEntity>> getContributions(
    String goalId,
  ) async {
    final models = await local.getContributions(goalId);
    return models.map((e) => e.toEntity()).toList();
  }
}

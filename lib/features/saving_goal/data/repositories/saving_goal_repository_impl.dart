import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

import 'package:spend_io_app/features/saving_goal/data/datasource/saving_goal_local_datasource.dart';
import 'package:spend_io_app/features/saving_goal/data/datasource/saving_goal_remote_datasource.dart';

import 'package:spend_io_app/features/saving_goal/data/models/saving_goal_contribution_model.dart';
import 'package:spend_io_app/features/saving_goal/data/models/saving_goal_model.dart';

import 'package:spend_io_app/features/saving_goal/domain/entities/saving_goal_contribution_entity.dart';
import 'package:spend_io_app/features/saving_goal/domain/entities/saving_goal_entity.dart';

import 'package:spend_io_app/features/saving_goal/domain/repositories/saving_goal_repository.dart';

class SavingGoalRepositoryImpl implements SavingGoalRepository {
  final SavingGoalLocalDatasource local;
  final SavingGoalRemoteDataSource remote;
  final Database db;

  SavingGoalRepositoryImpl({
    required this.local,
    required this.remote,
    required this.db,
  });

  // =========================================================
  // CACHE ENGINE
  // =========================================================

  Future<void> _updateGoalCache(String goalId) async {
    final contributionResult = await db.rawQuery(
      '''
      SELECT COALESCE(SUM(amount), 0) AS total
      FROM saving_goal_contributions
      WHERE goal_id = ?
      AND deleted_at IS NULL
      ''',
      [goalId],
    );

    final contributionTotal =
        (contributionResult.first['total'] as num).toDouble();

    final goalResult = await db.query(
      'saving_goals',
      columns: [
        'target_amount',
        'initial_amount',
        'status',
      ],
      where: 'id = ?',
      whereArgs: [goalId],
      limit: 1,
    );

    if (goalResult.isEmpty) return;

    final goal = goalResult.first;

    final targetAmount = (goal['target_amount'] as num).toDouble();

    final initialAmount = (goal['initial_amount'] as num).toDouble();

    final currentStatus = goal['status'] as String? ?? 'active';

    final currentAmount = initialAmount + contributionTotal;

    final progress = targetAmount <= 0 ? 0.0 : currentAmount / targetAmount;

    final normalizedProgress = progress.clamp(0.0, 1.0);

    String updatedStatus = currentStatus;

    if (currentStatus != 'archived') {
      updatedStatus = currentAmount >= targetAmount ? 'completed' : 'active';
    }

    await db.update(
      'saving_goals',
      {
        'cached_current_amount': currentAmount,
        'cached_progress': normalizedProgress,
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
  Future<List<SavingGoalEntity>> getGoals(
    int userId,
  ) async {
    final models = await local.getGoals(userId);

    return models.map((e) => e.toEntity()).toList();
  }

  // =========================================================
  // GET GOAL DETAIL
  // =========================================================

  @override
  Future<SavingGoalEntity?> getGoalById(
    String goalId,
  ) async {
    final model = await local.getGoalById(goalId);

    return model?.toEntity();
  }

  // =========================================================
  // CREATE GOAL
  // =========================================================

  @override
  Future<void> createGoal(
    SavingGoalEntity goal,
  ) async {
    final model = SavingGoalModel.fromEntity(goal);

    await local.insertGoal(model);

    try {
      await remote.syncGoal(model);
    } catch (_) {}
  }

  // =========================================================
  // UPDATE GOAL
  // =========================================================

  @override
  Future<void> updateGoal(
    SavingGoalEntity goal,
  ) async {
    final model = SavingGoalModel.fromEntity(goal);

    await local.updateGoal(model);

    try {
      await remote.syncGoal(model);
    } catch (_) {}

    await _updateGoalCache(goal.id);
  }

  // =========================================================
  // DELETE GOAL
  // =========================================================

  @override
  Future<void> deleteGoal({
    required String goalId,
    required int userId,
  }) async {
    debugPrint('Repository deleteGoal: $goalId');

    await local.deleteGoal(goalId);

    try {
      await remote.deleteGoal(goalId).timeout(const Duration(seconds: 4));
    } catch (e) {
      debugPrint('[Saving Goal Repo]: Cloud delete goal delayed ($e).');
    }

    await db.transaction((txn) async {
      await txn.update(
        'saving_goals',
        {'deleted_at': DateTime.now().toIso8601String()},
        where: 'id = ?',
        whereArgs: [goalId],
      );
    });

    debugPrint('Repository delete completed');
  }

  // =========================================================
  // ADD CONTRIBUTION
  // =========================================================

  @override
  Future<void> addContribution(
    SavingGoalContributionEntity contribution,
  ) async {
    final model = GoalContributionModel.fromEntity(
      contribution,
    );

    await local.insertContribution(model);

    try {
      await remote.syncContribution(model);
    } catch (_) {}

    await _updateGoalCache(
      contribution.goalId,
    );
  }

  // =========================================================
  // GET CONTRIBUTIONS
  // =========================================================

  @override
  Future<List<SavingGoalContributionEntity>> getContributions(
    String goalId,
  ) async {
    final models = await local.getContributions(goalId);

    return models.map((e) => e.toEntity()).toList();
  }
}

import 'package:spend_io_app/features/goal/domain/entities/goal_contribution_entity.dart';
import 'package:spend_io_app/features/goal/domain/entities/goal_entity.dart';

abstract class GoalRepository {
  Future<List<GoalEntity>> getGoals(int userId);

  Future<GoalEntity?> getGoalById(String goalId);

  Future<void> createGoal(GoalEntity goal);

  Future<void> updateGoal(GoalEntity goal);

  Future<void> deleteGoal({
    required String goalId,
    required int userId,
  });

  Future<void> addContribution(GoalContributionEntity contribution);

  Future<List<GoalContributionEntity>> getContributions(String goalId);
}

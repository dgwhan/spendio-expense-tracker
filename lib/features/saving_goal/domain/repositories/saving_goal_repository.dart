import 'package:spend_io_app/features/saving_goal/domain/entities/saving_goal_contribution_entity.dart';
import 'package:spend_io_app/features/saving_goal/domain/entities/saving_goal_entity.dart';

abstract class SavingGoalRepository {
  Future<List<SavingGoalEntity>> getGoals(int userId);

  Future<SavingGoalEntity?> getGoalById(String goalId);

  Future<void> createGoal(SavingGoalEntity goal);

  Future<void> updateGoal(SavingGoalEntity goal);

  Future<void> deleteGoal({
    required String goalId,
    required int userId,
  });

  Future<void> addContribution(SavingGoalContributionEntity contribution);

  Future<List<SavingGoalContributionEntity>> getContributions(String goalId);
}

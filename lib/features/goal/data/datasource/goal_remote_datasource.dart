import 'package:spend_io_app/features/goal/data/models/goal_contribution_model.dart';
import 'package:spend_io_app/features/goal/data/models/goal_model.dart';

abstract class GoalRemoteDataSource {
  Future<void> syncGoal(GoalModel goal);
  Future<void> syncContribution(GoalContributionModel contribution);
}

import 'package:spend_io_app/features/saving_goal/domain/entities/saving_goal_contribution_entity.dart';
import 'package:spend_io_app/features/saving_goal/domain/repositories/saving_goal_repository.dart';

class GetGoalContributionsUseCase {
  final SavingGoalRepository repository;

  GetGoalContributionsUseCase(this.repository);

  Future<List<SavingGoalContributionEntity>> call(
    String goalId,
  ) {
    return repository.getContributions(goalId);
  }
}

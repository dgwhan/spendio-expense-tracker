import 'package:spend_io_app/features/saving_goal/domain/entities/saving_goal_contribution_entity.dart';
import 'package:spend_io_app/features/saving_goal/domain/repositories/saving_goal_repository.dart';

class AddGoalContributionUseCase {
  final SavingGoalRepository repository;

  AddGoalContributionUseCase(this.repository);

  Future<void> call(
    SavingGoalContributionEntity contribution,
  ) {
    return repository.addContribution(
      contribution,
    );
  }
}

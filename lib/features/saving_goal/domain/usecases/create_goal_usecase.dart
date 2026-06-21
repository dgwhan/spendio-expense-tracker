import 'package:spend_io_app/features/saving_goal/domain/entities/saving_goal_entity.dart';
import 'package:spend_io_app/features/saving_goal/domain/repositories/saving_goal_repository.dart';

class CreateGoalUseCase {
  final SavingGoalRepository repository;

  CreateGoalUseCase(this.repository);

  Future<void> call(
    SavingGoalEntity goal,
  ) {
    return repository.createGoal(goal);
  }
}

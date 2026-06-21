import 'package:spend_io_app/features/saving_goal/domain/entities/saving_goal_entity.dart';
import 'package:spend_io_app/features/saving_goal/domain/repositories/saving_goal_repository.dart';

class UpdateGoalUseCase {
  final SavingGoalRepository repository;

  UpdateGoalUseCase(this.repository);

  Future<void> call(SavingGoalEntity goal) {
    return repository.updateGoal(goal);
  }
}

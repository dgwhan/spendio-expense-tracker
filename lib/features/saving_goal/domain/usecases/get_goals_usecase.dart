import 'package:spend_io_app/features/saving_goal/domain/entities/saving_goal_entity.dart';
import 'package:spend_io_app/features/saving_goal/domain/repositories/saving_goal_repository.dart';

class GetGoalsUseCase {
  final SavingGoalRepository repository;

  GetGoalsUseCase(this.repository);

  Future<List<SavingGoalEntity>> call(
    int userId,
  ) {
    return repository.getGoals(userId);
  }
}

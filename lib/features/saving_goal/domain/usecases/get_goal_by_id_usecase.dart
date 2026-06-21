import 'package:spend_io_app/features/saving_goal/domain/entities/saving_goal_entity.dart';
import 'package:spend_io_app/features/saving_goal/domain/repositories/saving_goal_repository.dart';

class GetGoalByIdUseCase {
  final SavingGoalRepository repository;

  GetGoalByIdUseCase(this.repository);

  Future<SavingGoalEntity?> call(
    String goalId,
  ) {
    return repository.getGoalById(goalId);
  }
}

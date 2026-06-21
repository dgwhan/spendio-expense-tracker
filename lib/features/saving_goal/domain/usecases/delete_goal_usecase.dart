import 'package:spend_io_app/features/saving_goal/domain/repositories/saving_goal_repository.dart';

class DeleteGoalUseCase {
  final SavingGoalRepository repository;

  DeleteGoalUseCase(this.repository);

  Future<void> call({
    required String goalId,
    required int userId,
  }) {
    return repository.deleteGoal(
      goalId: goalId,
      userId: userId,
    );
  }
}

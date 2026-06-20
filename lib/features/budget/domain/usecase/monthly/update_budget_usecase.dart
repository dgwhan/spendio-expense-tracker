import '../../entities/budget_entity.dart';
import '../../repositories/budget_repository.dart';

class UpdateBudgetUseCase {
  final BudgetRepository repository;

  UpdateBudgetUseCase(this.repository);

  Future<void> call({
    required int userId,
    required BudgetEntity budget,
  }) async {
    // optional safety guard
    if (budget.userId != userId) {
      throw Exception('User mismatch in UpdateBudgetUseCase');
    }

    await repository.updateBudget(budget);
  }
}

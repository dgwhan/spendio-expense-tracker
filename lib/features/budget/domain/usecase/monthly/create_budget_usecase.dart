import '../../entities/budget_entity.dart';
import '../../repositories/budget_repository.dart';

class CreateBudgetUseCase {
  final BudgetRepository repository;

  CreateBudgetUseCase(this.repository);

  Future<void> call(BudgetEntity budget) {
    return repository.createBudget(budget);
  }
}

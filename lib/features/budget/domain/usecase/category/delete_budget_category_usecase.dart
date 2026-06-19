import '../../repositories/budget_repository.dart';

class DeleteBudgetCategoryUseCase {
  final BudgetRepository repository;

  DeleteBudgetCategoryUseCase(this.repository);

  Future<void> call(String id) {
    return repository.deleteBudgetCategory(id);
  }
}

import '../../entities/category/budget_category_entity.dart';
import '../../repositories/budget_repository.dart';

class CreateBudgetCategoryUseCase {
  final BudgetRepository repository;

  CreateBudgetCategoryUseCase(this.repository);

  Future<void> call(BudgetCategoryEntity category) {
    return repository.createBudgetCategory(category);
  }
}

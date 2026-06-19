import '../../entities/category/budget_category_entity.dart';
import '../../repositories/budget_repository.dart';

class UpdateBudgetCategoryUseCase {
  final BudgetRepository repository;

  UpdateBudgetCategoryUseCase(this.repository);

  Future<void> call(BudgetCategoryEntity category) {
    return repository.updateBudgetCategory(category);
  }
}

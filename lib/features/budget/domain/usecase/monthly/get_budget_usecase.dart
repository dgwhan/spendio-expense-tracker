import '../../entities/category/budget_category_entity.dart';
import '../../repositories/budget_repository.dart';

class GetBudgetCategoriesUseCase {
  final BudgetRepository repository;

  GetBudgetCategoriesUseCase(this.repository);

  Future<List<BudgetCategoryEntity>> call(int userId) {
    return repository.getBudgetCategories(userId);
  }
}

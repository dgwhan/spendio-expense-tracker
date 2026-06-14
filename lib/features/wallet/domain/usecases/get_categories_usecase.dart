import '../entities/budget_category_entity.dart';
import '../repositories/budget_category_repository.dart';

class GetCategoriesUseCase {
  final BudgetCategoryRepository repository;

  GetCategoriesUseCase(this.repository);

  Future<List<BudgetCategoryEntity>> call(int localUserId) {
    return repository.getCategories(localUserId);
  }
}

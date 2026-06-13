import '../entities/budget_category_entity.dart';
import '../repositories/wallet_repository.dart';

class GetCategoriesUseCase {
  final WalletRepository repository;

  GetCategoriesUseCase(this.repository);

  Future<List<BudgetCategoryEntity>> call(int localUserId) {
    return repository.getCategories(localUserId);
  }
}

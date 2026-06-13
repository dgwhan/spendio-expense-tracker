import '../entities/budget_category_entity.dart';
import '../repositories/wallet_repository.dart';

class InitializeBudgetCategoriesUseCase {
  final WalletRepository repository;

  InitializeBudgetCategoriesUseCase(this.repository);

  Future<void> call(int localUserId) async {
    final existing = await repository.getCategories(localUserId);
    if (existing.isEmpty) {
      final defaults = [
        const BudgetCategoryEntity(id: 'dining', name: 'Dining', spent: 0.0, budget: 0.0),
        const BudgetCategoryEntity(id: 'transport', name: 'Transport', spent: 0.0, budget: 0.0),
        const BudgetCategoryEntity(id: 'shopping', name: 'Shopping', spent: 0.0, budget: 0.0),
        const BudgetCategoryEntity(id: 'health', name: 'Health', spent: 0.0, budget: 0.0),
        const BudgetCategoryEntity(id: 'bills', name: 'Bills', spent: 0.0, budget: 0.0),
        const BudgetCategoryEntity(id: 'entertainment', name: 'Entertainment', spent: 0.0, budget: 0.0),
      ];

      for (final category in defaults) {
        await repository.createCategory(localUserId, category);
      }
    }
  }
}

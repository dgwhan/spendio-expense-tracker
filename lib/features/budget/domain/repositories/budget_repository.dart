import 'package:spend_io_app/features/budget/domain/entities/category/budget_category_entity.dart';
import 'package:spend_io_app/features/budget/domain/entities/monthly/budget_entity.dart';

abstract class BudgetRepository {
  // =========================================================
  // MONTHLY BUDGET
  // =========================================================

  Future<BudgetEntity?> getCurrentBudget(int userId);

  Future<void> createBudget(BudgetEntity budget);

  Future<void> updateBudget(BudgetEntity budget);

  Future<void> deleteBudget(String budgetId);

  // =========================================================
  // CATEGORY BUDGET
  // =========================================================

  Future<List<BudgetCategoryEntity>> getBudgetCategories(
    int userId,
  );

  Future<void> createBudgetCategory(
    BudgetCategoryEntity category,
  );

  Future<void> updateBudgetCategory(
    BudgetCategoryEntity category,
  );

  Future<void> deleteBudgetCategory(
    String categoryBudgetId,
  );

  Future<bool> hasBudgetCategories(
    int userId,
  );
}

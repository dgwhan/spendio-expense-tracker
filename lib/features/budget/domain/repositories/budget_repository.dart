import 'package:spend_io_app/features/budget/domain/entities/budget_category_entity.dart';
import 'package:spend_io_app/features/budget/domain/entities/budget_entity.dart';

abstract class BudgetRepository {
  // --- Budget Tổng (CRUD thuần túy) ---
  Future<BudgetEntity?> getCurrentBudget(int userId);
  Future<void> createBudget(BudgetEntity budget);
  Future<void> updateBudget(BudgetEntity budget);
  Future<void> deleteBudget(String budgetId);

  // --- Budget Con Theo Danh Mục (CRUD thuần túy) ---
  Future<List<BudgetCategoryEntity>> getBudgetCategories(String budgetId);
  Future<void> createBudgetCategory(BudgetCategoryEntity category);
  Future<void> updateBudgetCategory(BudgetCategoryEntity category);
  Future<void> deleteBudgetCategory(String categoryBudgetId);
}

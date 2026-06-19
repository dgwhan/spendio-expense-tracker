import '../entities/category/budget_category_progress_entity.dart';
import '../repositories/budget_repository.dart';
import '../services/budget_progress_calculator.dart';

class GetBudgetCategoryProgressUseCase {
  final BudgetRepository repository;
  final BudgetProgressCalculator calculator;

  GetBudgetCategoryProgressUseCase({
    required this.repository,
    required this.calculator,
  });

  Future<List<BudgetCategoryProgressEntity>> call(int userId) {
    return calculator.calculateCategoryProgressList(userId: userId);
  }
}

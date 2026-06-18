import 'package:spend_io_app/features/budget/domain/entities/budget_category_progress_entity.dart';
import 'package:spend_io_app/features/budget/domain/entities/budget_entity.dart';
import 'package:spend_io_app/features/budget/domain/entities/budget_state.dart';

abstract class BudgetProgressCalculator {
  Future<BudgetState?> calculateBudgetProgress(BudgetEntity? budget);

  Future<List<BudgetCategoryProgressEntity>> calculateCategoryProgressList({
    required String budgetId,
    required DateTime startDate,
    required DateTime endDate,
  });
}

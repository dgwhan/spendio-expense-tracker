import 'package:spend_io_app/features/budget/domain/entities/category/budget_category_progress_entity.dart';
import 'package:spend_io_app/features/budget/domain/entities/monthly/budget_entity.dart';
import 'package:spend_io_app/features/budget/domain/entities/monthly/budget_progress_entity.dart';

abstract class BudgetProgressCalculator {
  Future<BudgetProgressEntity?> calculateBudgetProgress(
    BudgetEntity? budget,
  );

  Future<List<BudgetCategoryProgressEntity>> calculateCategoryProgressList({
    required int userId,
  });
}

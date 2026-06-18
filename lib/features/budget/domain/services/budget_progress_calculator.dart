import 'package:spend_io_app/features/budget/domain/entities/budget_category_progress_entity.dart';
import 'package:spend_io_app/features/budget/domain/entities/budget_entity.dart';
import 'package:spend_io_app/features/budget/domain/entities/budget_progress_entity.dart';

abstract class BudgetProgressCalculator {
  Future<BudgetProgressEntity?> calculateBudgetProgress(
    BudgetEntity? budget,
  );

  Future<List<BudgetCategoryProgressEntity>> calculateCategoryProgressList({
    required int userId,
  });
}

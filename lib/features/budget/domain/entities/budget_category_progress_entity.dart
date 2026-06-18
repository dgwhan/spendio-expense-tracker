import 'package:spend_io_app/features/budget/domain/entities/budget_category_entity.dart';

class BudgetCategoryProgressEntity {
  final BudgetCategoryEntity budgetCategory;

  final double spent;

  final double remaining;

  final double percentage;

  const BudgetCategoryProgressEntity({
    required this.budgetCategory,
    required this.spent,
    required this.remaining,
    required this.percentage,
  });
}

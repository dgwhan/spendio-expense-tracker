import 'package:spend_io_app/features/budget/domain/entities/budget_entity.dart';

class BudgetProgressEntity {
  final BudgetEntity budget;
  final double spent;
  final double remaining;
  final double percentage;

  const BudgetProgressEntity({
    required this.budget,
    required this.spent,
    required this.remaining,
    required this.percentage,
  });
}

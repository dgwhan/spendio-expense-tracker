import 'package:spend_io_app/features/budget/domain/entities/budget_entity.dart';

class BudgetState {
  final BudgetEntity budget;
  final double spent;
  final double remaining;
  final double percentage;

  const BudgetState({
    required this.budget,
    required this.spent,
    required this.remaining,
    required this.percentage,
  });
}

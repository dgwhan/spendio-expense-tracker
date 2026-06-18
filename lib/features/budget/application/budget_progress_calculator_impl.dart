import 'package:spend_io_app/features/budget/domain/entities/budget_category_progress_entity.dart';
import 'package:spend_io_app/features/budget/domain/entities/budget_entity.dart';
import 'package:spend_io_app/features/budget/domain/entities/budget_progress_entity.dart';
import 'package:spend_io_app/features/budget/domain/repositories/budget_repository.dart';
import 'package:spend_io_app/features/budget/domain/services/budget_progress_calculator.dart';
import 'package:spend_io_app/features/home/presentation/widgets/monthly_budget/widgets/budget_progress_bar.dart';
import 'package:spend_io_app/features/transaction/domain/repositories/transaction_repository.dart';

class BudgetProgressCalculatorImpl implements BudgetProgressCalculator {
  final BudgetRepository budgetRepository;
  final TransactionRepository transactionRepository;

  BudgetProgressCalculatorImpl({
    required this.budgetRepository,
    required this.transactionRepository,
  });

  @override
  Future<BudgetProgressEntity?> calculateBudgetProgress(
    BudgetEntity? budget,
  ) async {
    if (budget == null) return null;

    final totalSpent = await transactionRepository.getTotalSpentInPeriod(
      userId: budget.userId,
      startDate: budget.startDate,
      endDate: budget.endDate,
    );

    return BudgetProgressEntity(
      budget: budget,
      spent: totalSpent,
      remaining: budget.amount - totalSpent,
      percentage: budget.amount <= 0 ? 0.0 : totalSpent / budget.amount,
    );
  }

  @override
  Future<List<BudgetCategoryProgressEntity>> calculateCategoryProgressList({
    required int userId,
  }) async {
    final categories = await budgetRepository.getBudgetCategories(
      userId,
    );

    if (categories.isEmpty) {
      return [];
    }

    final List<BudgetCategoryProgressEntity> result = [];

    for (final categoryBudget in categories) {
      final spentMap = await transactionRepository.getSpentGroupByCategory(
        userId: userId,
        startDate: categoryBudget.startDate,
        endDate: categoryBudget.endDate,
      );

      final double spent = spentMap[categoryBudget.categoryId] ?? 0.0;

      final double remaining = categoryBudget.amount - spent;

      final double percentage =
          categoryBudget.amount <= 0 ? 0.0 : spent / categoryBudget.amount;

      result.add(
        BudgetCategoryProgressEntity(
          budgetCategory: categoryBudget,
          spent: spent,
          remaining: remaining,
          percentage: percentage,
        ),
      );
    }

    return result;
  }
}

import 'package:spend_io_app/features/budget/domain/entities/budget_category_entity.dart';
import 'package:spend_io_app/features/budget/domain/entities/budget_category_progress_entity.dart';
import 'package:spend_io_app/features/budget/domain/entities/budget_entity.dart';
import 'package:spend_io_app/features/budget/domain/entities/budget_state.dart';
import 'package:spend_io_app/features/budget/domain/repositories/budget_repository.dart';
import 'package:spend_io_app/features/budget/domain/services/budget_progress_calculator.dart';
import 'package:spend_io_app/features/transaction/domain/repositories/transaction_repository.dart';

class BudgetProgressCalculatorImpl implements BudgetProgressCalculator {
  final BudgetRepository budgetRepository;
  final TransactionRepository transactionRepository;

  BudgetProgressCalculatorImpl({
    required this.budgetRepository,
    required this.transactionRepository,
  });

  @override
  Future<BudgetState?> calculateBudgetProgress(BudgetEntity? budget) async {
    if (budget == null) return null;

    // 1 câu lệnh Query duy nhất lấy tổng chi tiêu của user trong mốc thời gian của Budget cha
    final double totalSpent = await transactionRepository.getTotalSpentInPeriod(
      userId: budget.userId,
      startDate: budget.startDate,
      endDate: budget.endDate,
    );

    return BudgetState(
      budget: budget,
      spent: totalSpent,
      remaining: budget.amount - totalSpent,
      percentage: budget.amount > 0 ? (totalSpent / budget.amount) : 0.0,
    );
  }

  @override
  Future<List<BudgetCategoryProgressEntity>> calculateCategoryProgressList({
    required String budgetId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    // Lấy danh sách toàn bộ budget con thuộc budget cha này
    final List<BudgetCategoryEntity> categories =
        await budgetRepository.getBudgetCategories(budgetId);

    if (categories.isEmpty) return [];

    //Gọi duy nhất 1 lần xuống TransactionRepository để lấy map thống kê
    final Map<String, double> spentMap =
        await transactionRepository.getSpentGroupByCategory(
      startDate: startDate,
      endDate: endDate,
    );

    //Map dữ liệu realtime on-the-fly cực kỳ nhanh trên RAM mà không đụng vào DB nữa
    return categories.map((catBudget) {
      final double spent = spentMap[catBudget.categoryId] ?? 0.0;
      final double remaining = catBudget.amount - spent;
      final double percentage =
          catBudget.amount > 0 ? (spent / catBudget.amount) : 0.0;

      return BudgetCategoryProgressEntity(
        budgetCategory: catBudget,
        spent: spent,
        remaining: remaining,
        percentage: percentage,
      );
    }).toList();
  }
}

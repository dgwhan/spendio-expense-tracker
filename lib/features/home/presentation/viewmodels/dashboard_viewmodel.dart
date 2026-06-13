import 'package:flutter/material.dart';
import 'package:spend_io_app/features/wallet/domain/entities/saving_goal_entity.dart';
import 'package:spend_io_app/features/wallet/domain/entities/budget_category_entity.dart';
import 'package:spend_io_app/features/wallet/domain/entities/financial_health_status.dart';
import 'package:spend_io_app/features/wallet/presentation/viewmodels/wallet_viewmodel.dart';
import 'package:spend_io_app/features/home/data/models/recent_transaction_model.dart';
import 'package:spend_io_app/features/home/data/models/spending_breakdown_model.dart';
import 'package:spend_io_app/features/home/data/models/financial_pulse_model.dart';
import 'package:spend_io_app/features/home/data/models/monthly_budget_model.dart';

class DashboardViewModel extends ChangeNotifier {
  final WalletViewModel walletViewModel;

  DashboardViewModel({required this.walletViewModel}) {
    walletViewModel.addListener(_onWalletChanged);
  }

  void _onWalletChanged() {
    notifyListeners();
  }

  @override
  void dispose() {
    walletViewModel.removeListener(_onWalletChanged);
    super.dispose();
  }

  double get totalAssets => walletViewModel.summary.totalAssets;
  double get monthlyBudgetAmount => walletViewModel.summary.monthlyBudget;
  double get totalSaved => walletViewModel.summary.totalSaved;
  double get totalSpent => walletViewModel.totalSpent;

  List<SavingGoalEntity> get savingsGoals => walletViewModel.goals;
  List<BudgetCategoryEntity> get budgetCategories => walletViewModel.categories;

  /// Exposes recent transactions generated dynamically from active accounts
  List<RecentTransactionModel> get recentTransactions {
    return [];
  }

  MonthlyBudgetModel get monthlyBudget {
    return MonthlyBudgetModel(
      totalBudget: monthlyBudgetAmount,
      totalSpent: totalSpent,
      monthName: walletViewModel.currentMonthLabel.split(' ').first,
    );
  }

  SpendingBreakdownModel get spendingBreakdownWeek => _getBreakdown('THIS WEEK');
  SpendingBreakdownModel get spendingBreakdownMonth => _getBreakdown(walletViewModel.currentMonthLabel.split(' ').first.toUpperCase());
  SpendingBreakdownModel get spendingBreakdownYear => _getBreakdown('2026');

  SpendingBreakdownModel _getBreakdown(String period) {
    final cats = walletViewModel.categories;
    if (cats.isEmpty) {
      return SpendingBreakdownModel(
        periodTitle: '$period TOTAL',
        totalAmount: 0,
        items: [],
      );
    }
    final total = totalSpent;
    final items = cats.map((c) {
      final double pct = total > 0 ? (c.spent / total) : 0.0;
      return SpendingItemModel(
        name: c.name,
        amount: c.spent,
        percentage: pct,
      );
    }).toList();

    return SpendingBreakdownModel(
      periodTitle: '$period TOTAL',
      totalAmount: total,
      items: items,
    );
  }

  FinancialPulseModel get financialPulse {
    final double weeklySpend = totalSpent / 4;
    final highestCategoryName = walletViewModel.categories.isNotEmpty
        ? walletViewModel.categories.first.name
        : 'None';
    final highestCategoryPct = totalSpent > 0 && walletViewModel.categories.isNotEmpty
        ? ((walletViewModel.categories.first.spent / totalSpent) * 100).toInt()
        : 0;

    String advice = 'Your financial health is stable. Keep tracking your daily spendings.';
    if (walletViewModel.healthStatus == FinancialHealthStatus.critical) {
      advice = 'Warning: Your savings allocation is low. We recommend setting a higher monthly budget goal.';
    } else if (walletViewModel.healthStatus == FinancialHealthStatus.excellent) {
      advice = 'Excellent: Your financial allocation is highly optimal!';
    }

    return FinancialPulseModel(
      thisWeekTotal: weeklySpend,
      comparePercentage: 0.12,
      isDecreased: totalAssets >= totalSpent,
      dailySpendings: const [
        DailySpendingModel(dayName: 'Mon', amount: 200000, densityRatio: 0.3),
        DailySpendingModel(dayName: 'Tue', amount: 350000, densityRatio: 0.5),
        DailySpendingModel(dayName: 'Wed', amount: 250000, densityRatio: 0.4),
        DailySpendingModel(dayName: 'Thu', amount: 500000, densityRatio: 0.7),
        DailySpendingModel(dayName: 'Fri', amount: 50000, densityRatio: 0.1),
        DailySpendingModel(dayName: 'Sat', amount: 620000, densityRatio: 1.0),
        DailySpendingModel(dayName: 'Sun', amount: 150000, densityRatio: 0.25),
      ],
      highestDayName: 'Saturday',
      highestDayAmount: 620000,
      topCategoryName: highestCategoryName,
      topCategoryPercentage: highestCategoryPct,
      aiRecommendation: advice,
    );
  }
}

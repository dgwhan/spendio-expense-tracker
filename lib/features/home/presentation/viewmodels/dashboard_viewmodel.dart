import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spend_io_app/features/wallet/domain/entities/saving_goal_entity.dart';
import 'package:spend_io_app/features/wallet/domain/entities/financial_health_status.dart';
import 'package:spend_io_app/features/wallet/presentation/viewmodels/wallet_viewmodel.dart';
import 'package:spend_io_app/features/account/presentation/viewmodels/account_viewmodel.dart';
import 'package:spend_io_app/features/transaction/presentation/viewmodels/transaction_viewmodel.dart';
import 'package:spend_io_app/features/transaction/domain/entities/transaction_type.dart';
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

  // 🌐 Helper chuyển ID danh mục từ database sang tên hiển thị Tiếng Việt trên giao diện Home
  String _getCategoryDisplayName(String categoryId) {
    switch (categoryId.toLowerCase()) {
      case 'dining':
      case 'food':
        return 'Ăn uống';
      case 'transport':
        return 'Di chuyển';
      case 'shopping':
        return 'Mua sắm';
      case 'health':
        return 'Sức khỏe';
      case 'bills':
        return 'Hóa đơn';
      case 'entertainment':
        return 'Giải trí';
      default:
        return categoryId;
    }
  }

  // 🌟 RECENT TRANSACTIONS: Nạp động danh sách lịch sử giao dịch gần đây ra màn hình chính
  List<RecentTransactionModel> getRecentTransactions(BuildContext context) {
    final List<RecentTransactionModel> allTxs = [];

    final activeAccounts = context.read<AccountViewModel>().accounts;
    final sourceTransactions =
        context.read<TransactionViewModel>().state.transactions;

    if (activeAccounts.isEmpty || sourceTransactions.isEmpty) {
      return [];
    }

    for (final tx in sourceTransactions) {
      String displayTitle = tx.note ?? '';
      final String categoryName = _getCategoryDisplayName(tx.categoryId);

      if (displayTitle.trim().isEmpty) {
        displayTitle = categoryName;
      }

      allTxs.add(
        RecentTransactionModel(
          id: tx.id,
          title: displayTitle,
          category: categoryName,
          amount: tx.amount,
          date: tx.transactionDate,
          isExpense: tx.type == TransactionType.expense,
        ),
      );
    }

    allTxs.sort((a, b) => b.date.compareTo(a.date));
    return allTxs.take(10).toList();
  }

  // 📊 MONTHLY BUDGET SUMMARY: Thống kê ngân sách tổng quát của tháng hiển thị ở Home
  MonthlyBudgetModel get monthlyBudget {
    return MonthlyBudgetModel(
      totalBudget: monthlyBudgetAmount,
      totalSpent: totalSpent,
      monthName: walletViewModel.currentMonthLabel.split(' ').first,
    );
  }

  // 📈 SPENDING BREAKDOWN: Phân tích cơ cấu chi tiêu theo thời gian
  SpendingBreakdownModel get spendingBreakdownWeek =>
      _getBreakdown('THIS WEEK');
  SpendingBreakdownModel get spendingBreakdownMonth => _getBreakdown(
      walletViewModel.currentMonthLabel.split(' ').first.toUpperCase());
  SpendingBreakdownModel get spendingBreakdownYear => _getBreakdown('2026');

  SpendingBreakdownModel _getBreakdown(String period) {
    final progressList = walletViewModel.categoriesProgress;
    if (progressList.isEmpty) {
      return SpendingBreakdownModel(
        periodTitle: '$period TOTAL',
        totalAmount: 0,
        items: [],
      );
    }

    final total = totalSpent;
    final items = progressList.map((progressItem) {
      final double pct = total > 0 ? (progressItem.spent / total) : 0.0;
      return SpendingItemModel(
        name: _getCategoryDisplayName(progressItem.budgetCategory.categoryId),
        amount: progressItem.spent,
        percentage: pct,
      );
    }).toList();

    return SpendingBreakdownModel(
      periodTitle: '$period TOTAL',
      totalAmount: total,
      items: items,
    );
  }

  // 🩺 FINANCIAL PULSE: Đo lường sức khỏe tài chính và vẽ biểu đồ mật độ chi tiêu hàng tuần
  FinancialPulseModel get financialPulse {
    final double weeklySpend = totalSpent / 4;
    final progressList = walletViewModel.categoriesProgress;

    final highestCategoryName = progressList.isNotEmpty
        ? _getCategoryDisplayName(progressList.first.budgetCategory.categoryId)
        : 'None';

    final highestCategoryPct = totalSpent > 0 && progressList.isNotEmpty
        ? ((progressList.first.spent / totalSpent) * 100).toInt()
        : 0;

    String advice =
        'Your financial health is stable. Keep tracking your daily spendings.';
    if (walletViewModel.healthStatus == FinancialHealthStatus.critical) {
      advice =
          'Warning: Your savings allocation is low. We recommend setting a higher monthly budget goal.';
    } else if (walletViewModel.healthStatus ==
        FinancialHealthStatus.excellent) {
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

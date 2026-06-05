import 'package:spend_io_app/features/dashboard/datasource/models/budget_category_model.dart';
import 'package:spend_io_app/features/dashboard/datasource/models/dashboard_summary_model.dart';
import 'package:spend_io_app/features/dashboard/datasource/models/financial_pulse_model.dart';
import 'package:spend_io_app/features/dashboard/datasource/models/monthly_budget_model.dart';
import 'package:spend_io_app/features/dashboard/datasource/models/recent_transaction_model.dart';
import 'package:spend_io_app/features/dashboard/datasource/models/savings_goal_model.dart';
import 'package:spend_io_app/features/dashboard/datasource/models/spending_breakdown_model.dart';

class DashboardMockData {
  static const summary = DashboardSummaryModel(
    balance: 24500000,
    income: 18000000,
    expense: 7200000,
    savings: 10800000,
  );

  static final List<RecentTransactionModel> recentTransactions = [
    RecentTransactionModel(
      id: '1',
      title: 'Highlands Coffee',
      category: 'Food',
      amount: 55000,
      date: DateTime.now(),
      isExpense: true,
    ),
    RecentTransactionModel(
      id: '2',
      title: 'Grab Bike',
      category: 'Transport',
      amount: 32000,
      date: DateTime.now(),
      isExpense: true,
    ),
    RecentTransactionModel(
      id: '3',
      title: 'WinMart+',
      category: 'Shopping',
      amount: 120000,
      date: DateTime.now(),
      isExpense: true,
    ),
    RecentTransactionModel(
      id: '4',
      title: 'Salary',
      category: 'Income',
      amount: 8000000,
      date: DateTime.now(),
      isExpense: false,
    ),
  ];

  static const budgetCategories = [
    BudgetCategoryModel(
      id: '1',
      name: 'Dining',
      spent: 2100000,
      budget: 5000000,
      icon: '',
    ),
    BudgetCategoryModel(
      id: '2',
      name: 'Transport',
      spent: 800000,
      budget: 2000000,
      icon: '',
    ),
    BudgetCategoryModel(
      id: '3',
      name: 'Shopping',
      spent: 3500000,
      budget: 6000000,
      icon: '',
    ),
    BudgetCategoryModel(
      id: '4',
      name: 'Health',
      spent: 400000,
      budget: 1500000,
      icon: '',
    ),
    BudgetCategoryModel(
      id: '5',
      name: 'Bills',
      spent: 1200000,
      budget: 3000000,
      icon: '',
    ),
    BudgetCategoryModel(
      id: '6',
      name: 'Entertainment',
      spent: 900000,
      budget: 2500000,
      icon: '',
    ),
  ];

  static const monthlyBudget = MonthlyBudgetModel(
    totalBudget: 20000000,
    totalSpent: 11200000,
    monthName: 'June',
  );

  static const List<SavingsGoalModel> savingsGoals = [
    SavingsGoalModel(
      id: '1',
      title: 'Emergency Fund',
      category: 'Finance',
      currentAmount: 85000000,
      targetAmount: 100000000,
      status: 'GREAT PROGRESS',
      iconType: 'finance',
    ),
    SavingsGoalModel(
      id: '2',
      title: 'New Tesla',
      category: 'Vehicle',
      currentAmount: 120000000,
      targetAmount: 1500000000,
      status: 'ON TRACK',
      iconType: 'vehicle',
    ),
  ];

  // chia theo tuần
  static const spendingBreakdownWeek = SpendingBreakdownModel(
    periodTitle: 'THIS WEEK TOTAL',
    totalAmount: 4200000,
    items: [
      SpendingItemModel(
          name: 'Food & Drink', amount: 2100000, percentage: 0.50),
      SpendingItemModel(name: 'Transport', amount: 1050000, percentage: 0.25),
      SpendingItemModel(
          name: 'Entertainment', amount: 630000, percentage: 0.15),
      SpendingItemModel(name: 'Others', amount: 420000, percentage: 0.10),
    ],
  );

  // chia theo tháng
  static const spendingBreakdownMonth = SpendingBreakdownModel(
    periodTitle: 'JUNE TOTAL',
    totalAmount: 33700000,
    items: [
      SpendingItemModel(
          name: 'Food & Drink', amount: 15165000, percentage: 0.45),
      SpendingItemModel(name: 'Transport', amount: 8425000, percentage: 0.25),
      SpendingItemModel(
          name: 'Entertainment', amount: 5055000, percentage: 0.15),
      SpendingItemModel(name: 'Others', amount: 5055000, percentage: 0.15),
    ],
  );

  // chia theo năm
  static const spendingBreakdownYear = SpendingBreakdownModel(
    periodTitle: '2026 TOTAL',
    totalAmount: 185000000,
    items: [
      SpendingItemModel(
          name: 'Food & Drink', amount: 74000000, percentage: 0.40),
      SpendingItemModel(name: 'Transport', amount: 55500000, percentage: 0.30),
      SpendingItemModel(
          name: 'Entertainment', amount: 37000000, percentage: 0.20),
      SpendingItemModel(name: 'Others', amount: 18500000, percentage: 0.10),
    ],
  );

  static const financialPulse = FinancialPulseModel(
    thisWeekTotal: 28500000,
    comparePercentage: 0.12,
    isDecreased: true,
    dailySpendings: [
      DailySpendingModel(dayName: 'Mon', amount: 2000000, densityRatio: 0.3),
      DailySpendingModel(dayName: 'Tue', amount: 3500000, densityRatio: 0.5),
      DailySpendingModel(dayName: 'Wed', amount: 2500000, densityRatio: 0.4),
      DailySpendingModel(dayName: 'Thu', amount: 5000000, densityRatio: 0.7),
      DailySpendingModel(dayName: 'Fri', amount: 500000, densityRatio: 0.1),
      DailySpendingModel(dayName: 'Sat', amount: 6200000, densityRatio: 1.0),
      DailySpendingModel(dayName: 'Sun', amount: 1500000, densityRatio: 0.25),
    ],
    highestDayName: 'Saturday',
    highestDayAmount: 6200000,
    topCategoryName: 'Food & Drink',
    topCategoryPercentage: 42,
    aiRecommendation:
        'Your spending decreased this week, but food and drink remains your largest category.',
  );
}

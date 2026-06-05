import 'package:spend_io_app/features/dashboard/datasource/models/budget_category_model.dart';
import 'package:spend_io_app/features/dashboard/datasource/models/dashboard_summary_model.dart';
import 'package:spend_io_app/features/dashboard/datasource/models/monthly_budget_model.dart';
import 'package:spend_io_app/features/dashboard/datasource/models/recent_transaction_model.dart';

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
}

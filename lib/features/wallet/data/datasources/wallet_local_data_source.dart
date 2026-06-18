import 'package:spend_io_app/features/budget/data/datasources/budget_local_data_source.dart'; // Đã trỏ đúng nguồn chuẩn
import 'package:spend_io_app/features/budget/data/models/budget_model.dart';
import 'package:spend_io_app/features/budget/data/models/budget_category_model.dart';
import 'package:spend_io_app/features/account/data/models/account_model.dart';
import 'package:spend_io_app/features/wallet/data/models/saving_goal_model.dart';
import 'package:spend_io_app/features/account/data/datasource/account_local_data_source.dart';
import 'package:spend_io_app/features/wallet/data/datasources/goal/goal_local_data_source.dart';

/// Facade aggregates all local datasources.
/// Consumers depend on this single contract; sub-sources handle the detail.
abstract class WalletLocalDataSource
    implements
        AccountLocalDataSource,
        GoalLocalDataSource,
        BudgetLocalDataSource {}

class WalletLocalDataSourceImpl implements WalletLocalDataSource {
  final AccountLocalDataSource _accountLocal;
  final GoalLocalDataSource _goalLocal;
  final BudgetLocalDataSource _budgetLocal;

  WalletLocalDataSourceImpl({
    required AccountLocalDataSource accountLocal,
    required GoalLocalDataSource goalLocal,
    required BudgetLocalDataSource budgetLocal,
  })  : _accountLocal = accountLocal,
        _goalLocal = goalLocal,
        _budgetLocal = budgetLocal;

  // =====================================================================
  // 1. ACCOUNT MODULE SUB-ROUTING
  // =====================================================================
  @override
  Future<List<AccountModel>> getAccounts(int userId) =>
      _accountLocal.getAccounts(userId);

  @override
  Future<void> saveAccount(int userId, AccountModel account) =>
      _accountLocal.saveAccount(userId, account);

  @override
  Future<void> createAccount(int userId, AccountModel account) =>
      _accountLocal.createAccount(userId, account);

  @override
  Future<void> updateAccount(int userId, AccountModel account) =>
      _accountLocal.updateAccount(userId, account);

  @override
  Future<void> deleteAccount(String accountId) =>
      _accountLocal.deleteAccount(accountId);

  @override
  Future<void> softDeleteAccount(String accountId) =>
      _accountLocal.softDeleteAccount(accountId);

  @override
  Future<void> restoreAccount(String accountId) =>
      _accountLocal.restoreAccount(accountId);

  @override
  Future<bool> hasAccounts(int userId) => _accountLocal.hasAccounts(userId);

  // =====================================================================
  // 2. SAVINGS GOAL MODULE SUB-ROUTING
  // =====================================================================
  @override
  Future<List<SavingGoalModel>> getGoals(int userId) =>
      _goalLocal.getGoals(userId);

  @override
  Future<void> saveGoal(int userId, SavingGoalModel goal) =>
      _goalLocal.saveGoal(userId, goal);

  @override
  Future<void> deleteGoal(String goalId) => _goalLocal.deleteGoal(goalId);

  @override
  Future<bool> hasGoals(int userId) => _goalLocal.hasGoals(userId);

  // =====================================================================
  // 3. BUDGET MODULE SUB-ROUTING (🔴 ĐÃ CẬP NHẬT THEO SCHEMAS MỚI CHUẨN)
  // =====================================================================
  @override
  Future<BudgetModel?> getCurrentBudget(int userId) =>
      _budgetLocal.getCurrentBudget(userId);

  @override
  Future<void> createBudget(BudgetModel budget) =>
      _budgetLocal.createBudget(budget);

  @override
  Future<void> updateBudget(BudgetModel budget) =>
      _budgetLocal.updateBudget(budget);

  @override
  Future<void> deleteBudget(String budgetId) =>
      _budgetLocal.deleteBudget(budgetId);

  @override
  Future<List<BudgetCategoryModel>> getBudgetCategories(String budgetId) =>
      _budgetLocal.getBudgetCategories(budgetId);

  @override
  Future<void> createBudgetCategory(BudgetCategoryModel category) =>
      _budgetLocal.createBudgetCategory(category);

  @override
  Future<void> updateBudgetCategory(BudgetCategoryModel category) =>
      _budgetLocal.updateBudgetCategory(category);

  @override
  Future<void> deleteBudgetCategory(String id) =>
      _budgetLocal.deleteBudgetCategory(id);

  // 🔴 ĐÃ VÁ LỖI TRỰC TIẾP: Trỏ đúng sang hàm hasCategories an toàn của BudgetLocalDataSource chuẩn mới
  @override
  Future<bool> hasCategories(int userId) => _budgetLocal.hasCategories(userId);
}

import '../models/account_model.dart';
import '../models/saving_goal_model.dart';
import '../models/budget_category_model.dart';
import 'account/account_local_data_source.dart';
import 'goal/goal_local_data_source.dart';
import 'budget/budget_local_data_source.dart';

/// Facade that aggregates all local datasources.
/// Consumers depend on this single contract; sub-sources handle the detail.
abstract class WalletLocalDataSource
    implements AccountLocalDataSource, GoalLocalDataSource, BudgetLocalDataSource {}

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

  // ── Account ────────────────────────────────────────────────────────────────

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
  Future<bool> hasAccounts(int userId) =>
      _accountLocal.hasAccounts(userId);

  // ── Goal ──────────────────────────────────────────────────────────────────

  @override
  Future<List<SavingGoalModel>> getGoals(int userId) =>
      _goalLocal.getGoals(userId);

  @override
  Future<void> saveGoal(int userId, SavingGoalModel goal) =>
      _goalLocal.saveGoal(userId, goal);

  @override
  Future<void> deleteGoal(String goalId) =>
      _goalLocal.deleteGoal(goalId);

  @override
  Future<bool> hasGoals(int userId) =>
      _goalLocal.hasGoals(userId);

  // ── Budget ────────────────────────────────────────────────────────────────

  @override
  Future<List<BudgetCategoryModel>> getCategories(int userId) =>
      _budgetLocal.getCategories(userId);

  @override
  Future<void> insertCategory(int userId, BudgetCategoryModel category) =>
      _budgetLocal.insertCategory(userId, category);

  @override
  Future<void> updateCategory(int userId, BudgetCategoryModel category) =>
      _budgetLocal.updateCategory(userId, category);

  @override
  Future<bool> hasCategories(int userId) =>
      _budgetLocal.hasCategories(userId);
}

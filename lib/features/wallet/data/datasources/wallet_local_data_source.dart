import 'package:spend_io_app/features/budget/data/datasources/budget_local_data_source.dart';
import 'package:spend_io_app/features/budget/data/models/budget_model.dart';
import 'package:spend_io_app/features/budget/data/models/budget_category_model.dart';
import 'package:spend_io_app/features/account/data/datasource/account_local_data_source.dart';
import 'package:spend_io_app/features/account/data/models/account_model.dart';

abstract class WalletLocalDataSource
    implements AccountLocalDataSource, BudgetLocalDataSource {}

class WalletLocalDataSourceImpl implements WalletLocalDataSource {
  final AccountLocalDataSource _accountLocal;
  final BudgetLocalDataSource _budgetLocal;

  WalletLocalDataSourceImpl({
    required AccountLocalDataSource accountLocal,
    required BudgetLocalDataSource budgetLocal,
  })  : _accountLocal = accountLocal,
        _budgetLocal = budgetLocal;

  // =========================================================
  // ACCOUNT
  // =========================================================

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

  // =========================================================
  // BUDGET
  // =========================================================

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
  Future<List<BudgetCategoryModel>> getBudgetCategories({
    required int userId,
  }) =>
      _budgetLocal.getBudgetCategories(userId: userId);

  @override
  Future<void> createBudgetCategory(BudgetCategoryModel category) =>
      _budgetLocal.createBudgetCategory(category);

  @override
  Future<void> updateBudgetCategory(BudgetCategoryModel category) =>
      _budgetLocal.updateBudgetCategory(category);

  @override
  Future<void> deleteBudgetCategory(String id) =>
      _budgetLocal.deleteBudgetCategory(id);

  @override
  Future<List<BudgetCategoryModel>> getBudgetCategoriesByPeriod({
    required int userId,
    required DateTime date,
  }) =>
      _budgetLocal.getBudgetCategoriesByPeriod(
        userId: userId,
        date: date,
      );

  @override
  Future<bool> hasBudgetCategories(int userId) =>
      _budgetLocal.hasBudgetCategories(userId);
}

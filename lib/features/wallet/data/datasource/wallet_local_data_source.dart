import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import '../../../../core/database/app_database.dart';
import '../../domain/entities/account_entity.dart';
import '../../domain/entities/budget_category_entity.dart';
import '../../domain/entities/quick_action_entity.dart';
import '../../domain/entities/saving_goal_entity.dart';
import '../../domain/entities/wallet_summary_entity.dart';
import '../models/account_model.dart';
import '../models/saving_goal_model.dart';

abstract class WalletLocalDataSource {
  Future<List<AccountModel>> getAccounts(int userId);
  Future<void> saveAccount(int userId, AccountModel account);
  Future<void> deleteAccount(String accountId);

  Future<List<SavingGoalModel>> getGoals(int userId);
  Future<void> saveGoal(int userId, SavingGoalModel goal);
  Future<void> deleteGoal(String goalId);

  List<BudgetCategoryEntity> getCategories();

  static const summary = WalletSummaryEntity(
    totalAssets: 24500,
    monthlyBudget: 1200,
    totalSaved: 8500,
    activeGoals: 4,
  );

  static const List<QuickActionEntity> kQuickActions = [
    QuickActionEntity(
      title: 'Add Budget',
      icon: Icons.account_balance_wallet_outlined,
      type: QuickActionType.addBudget,
    ),
    QuickActionEntity(
      title: 'Add Account',
      icon: Icons.account_balance_outlined,
      type: QuickActionType.addAccount,
    ),
    QuickActionEntity(
      title: 'Add Goal',
      icon: Icons.flag_outlined,
      type: QuickActionType.addGoal,
    ),
    QuickActionEntity(
      title: 'Transfer',
      icon: Icons.swap_horiz,
      type: QuickActionType.transfer,
    ),
  ];

  static const List<BudgetCategoryEntity> categories = [
    BudgetCategoryEntity(
      id: 'cat_1',
      name: 'Dining',
      spent: 450.00,
      budget: 600.00,
    ),
    BudgetCategoryEntity(
      id: 'cat_2',
      name: 'Transport',
      spent: 120.00,
      budget: 200.00,
    ),
    BudgetCategoryEntity(
      id: 'cat_3',
      name: 'Shopping',
      spent: 250.00,
      budget: 300.00,
    ),
    BudgetCategoryEntity(
      id: 'cat_4',
      name: 'Bills',
      spent: 80.00,
      budget: 100.00,
    ),
  ];

  static const accounts = [
    AccountEntity(
      id: 'acc_01',
      name: 'Cash Wallet',
      type: AccountType.cash,
      balance: 320,
      icon: Icons.wallet,
    ),
    AccountEntity(
      id: 'acc_02',
      name: 'Vietcombank',
      type: AccountType.bank,
      balance: 5800,
      icon: Icons.account_balance,
    ),
    AccountEntity(
      id: 'acc_03',
      name: 'Momo',
      type: AccountType.eWallet,
      balance: 950,
      icon: Icons.account_balance_wallet,
    ),
    AccountEntity(
      id: 'acc_04',
      name: 'Visa Credit',
      type: AccountType.creditCard,
      balance: -1200,
      icon: Icons.credit_card,
    ),
  ];

  static final goals = [
    SavingGoalEntity(
      id: 'goal_01',
      name: 'MacBook Pro',
      currentAmount: 1200,
      targetAmount: 2500,
      estimatedDate: DateTime(2026, 12, 1),
      icon: Icons.laptop_mac,
    ),
    SavingGoalEntity(
      id: 'goal_02',
      name: 'Japan Trip',
      currentAmount: 3200,
      targetAmount: 6000,
      estimatedDate: DateTime(2027, 3, 1),
      icon: Icons.flight,
    ),
  ];
}

class WalletLocalDataSourceImpl implements WalletLocalDataSource {
  Future<Database> get _db async => await AppDatabase.database;

  @override
  Future<List<AccountModel>> getAccounts(int userId) async {
    final db = await _db;
    final result = await db.query(
      'wallets',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );
    return result.map((map) => AccountModel.fromMap(map)).toList();
  }

  @override
  Future<void> saveAccount(int userId, AccountModel account) async {
    final db = await _db;
    final map = account.toMap();
    map['user_id'] = userId;
    await db.insert(
      'wallets',
      map,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> deleteAccount(String accountId) async {
    final db = await _db;
    await db.delete(
      'wallets',
      where: 'id = ?',
      whereArgs: [accountId],
    );
  }

  @override
  Future<List<SavingGoalModel>> getGoals(int userId) async {
    final db = await _db;
    final result = await db.query(
      'financial_goals',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );
    return result.map((map) => SavingGoalModel.fromMap(map)).toList();
  }

  @override
  Future<void> saveGoal(int userId, SavingGoalModel goal) async {
    final db = await _db;
    final map = goal.toMap();
    map['user_id'] = userId;
    await db.insert(
      'financial_goals',
      map,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> deleteGoal(String goalId) async {
    final db = await _db;
    await db.delete(
      'financial_goals',
      where: 'id = ?',
      whereArgs: [goalId],
    );
  }

  @override
  List<BudgetCategoryEntity> getCategories() {
    return WalletLocalDataSource.categories;
  }
}

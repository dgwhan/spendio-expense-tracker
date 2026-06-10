import 'package:flutter/material.dart';
import 'package:spend_io_app/features/wallet/domain/entities/budget_category_entity.dart';
import 'package:spend_io_app/features/wallet/domain/entities/quick_action_entity.dart';
import 'package:spend_io_app/features/wallet/domain/entities/wallet_summary_entity.dart';

class WalletMockData {
  WalletMockData._();

  /// fake wallet summary
  ///
  /// TODO:replaced by:
  /// repository: sqlite/firebase
  static const summary = WalletSummaryEntity(
    totalAssets: 24500,
    monthlyBudget: 1200,
    totalSaved: 8500,
    activeGoals: 4,
  );

  /// quick actions
  static const quickActions = [
    QuickActionEntity(
      title: 'Add Budget',
      icon: Icons.account_balance_wallet_outlined,
    ),
    QuickActionEntity(
      title: 'Add Account',
      icon: Icons.account_balance_outlined,
    ),
    QuickActionEntity(
      title: 'Add Goal',
      icon: Icons.flag_outlined,
    ),
    QuickActionEntity(
      title: 'Transfer',
      icon: Icons.swap_horiz,
    ),
  ];

  //budget category
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
}

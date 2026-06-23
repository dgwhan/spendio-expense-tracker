import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:spend_io_app/features/home/data/models/dashboard_summary_model.dart';
import 'package:spend_io_app/features/home/data/models/financial_pulse_model.dart';
import 'package:spend_io_app/features/home/data/models/recent_transaction_model.dart';
import 'package:spend_io_app/features/home/data/models/spending_breakdown_model.dart';

import 'package:spend_io_app/features/wallet/presentation/viewmodels/wallet_viewmodel.dart';
import 'package:spend_io_app/features/transaction/presentation/viewmodels/transaction_viewmodel.dart';
import 'package:spend_io_app/features/category/presentation/viewmodels/category_viewmodel.dart';
import 'package:spend_io_app/features/transaction/domain/entities/transaction_entity.dart';
import 'package:spend_io_app/features/transaction/domain/entities/transaction_type.dart';
import 'package:spend_io_app/features/category/domain/entities/category_entity.dart';
import 'package:spend_io_app/core/currency/convert_currency_use_case.dart';
import 'package:spend_io_app/core/currency/exchange_rate_provider.dart';
import 'package:spend_io_app/core/currency/currency_context.dart';

class HomeViewModel extends ChangeNotifier {
  WalletViewModel walletViewModel;
  final ConvertCurrencyUseCase _convertCurrency = const ConvertCurrencyUseCase(LocalExchangeRateProvider());

  HomeViewModel({required this.walletViewModel});

  void updateWallet(WalletViewModel newWalletVM) {
    walletViewModel = newWalletVM;
    notifyListeners();
  }

  // SUMMARY

  DashboardSummaryModel getSummary(BuildContext context, List<TransactionEntity> transactions) {
    final w = walletViewModel.summary;
    final preferredCurrencyCode = context.currencyContext.preferredCurrencyCode;

    double totalIncome = 0;
    double totalExpense = 0;

    for (final tx in transactions) {
      final double convertedAmount = _convertCurrency.execute(
        amount: tx.amount,
        from: tx.currencyCode,
        to: preferredCurrencyCode,
      );
      if (tx.type == TransactionType.income) {
        totalIncome += convertedAmount;
      } else if (tx.type == TransactionType.expense) {
        totalExpense += convertedAmount;
      }
    }

    return DashboardSummaryModel(
      balance: w.totalAssets,
      income: totalIncome,
      expense: totalExpense,
      savings: w.totalSaved,
    );
  }

  // CATEGORY RESOLVER (SAFE + FEATURE-BASED)

  String _resolveCategoryName(BuildContext context, String categoryId) {
    final categoryVM = context.read<CategoryViewModel>();

    final categories = categoryVM.state.categories;

    final CategoryEntity? match = categories
        .where((c) => c.id == categoryId)
        .cast<CategoryEntity?>()
        .firstWhere(
          (e) => e != null,
          orElse: () => null,
        );

    return match?.name ?? categoryId;
  }

  // RECENT TRANSACTIONS

  List<RecentTransactionModel> getRecentTransactions(BuildContext context) {
    final txVM = context.read<TransactionViewModel>();
    final txs = txVM.state.transactions;

    final list = txs.map((tx) {
      return RecentTransactionModel(
        id: tx.id,
        title: tx.note ?? tx.categoryId,
        category: _resolveCategoryName(context, tx.categoryId),
        amount: tx.amount,
        date: tx.transactionDate,
        isExpense: tx.type == TransactionType.expense,
        currencyCode: tx.currencyCode,
      );
    }).toList();

    list.sort((a, b) => b.date.compareTo(a.date));
    return list.take(10).toList();
  }

  // SPENDING BREAKDOWN

  SpendingBreakdownModel getSpendingBreakdownForPeriod(
      BuildContext context, String period) {
    final txVM = context.read<TransactionViewModel>();
    final txs = txVM.state.transactions;
    final preferredCurrencyCode = context.currencyContext.preferredCurrencyCode;

    final now = DateTime.now();
    DateTime threshold;

    if (period == 'Week') {
      threshold = now.subtract(const Duration(days: 7));
    } else if (period == 'Year') {
      threshold = DateTime(now.year, 1, 1);
    } else {
      // Month
      threshold = DateTime(now.year, now.month, 1);
    }

    final expenses = txs.where((t) {
      return t.type == TransactionType.expense &&
          t.transactionDate.isAfter(threshold);
    }).toList();

    double total = 0.0;
    final Map<String, double> grouped = {};

    for (final t in expenses) {
      final double convertedAmount = _convertCurrency.execute(
        amount: t.amount,
        from: t.currencyCode,
        to: preferredCurrencyCode,
      );
      total += convertedAmount;
      grouped[t.categoryId] = (grouped[t.categoryId] ?? 0) + convertedAmount;
    }

    final items = grouped.entries.map((e) {
      return SpendingItemModel(
        name: _resolveCategoryName(context, e.key),
        amount: e.value,
        percentage: total == 0 ? 0 : e.value / total,
      );
    }).toList();

    return SpendingBreakdownModel(
      periodTitle: period == 'Week'
          ? 'THIS WEEK'
          : (period == 'Year' ? 'THIS YEAR' : 'THIS MONTH'),
      totalAmount: total,
      items: items,
    );
  }

  SpendingBreakdownModel getSpendingBreakdown(BuildContext context) {
    final txVM = context.read<TransactionViewModel>();
    final txs = txVM.state.transactions;
    final preferredCurrencyCode = context.currencyContext.preferredCurrencyCode;

    final expenses =
        txs.where((t) => t.type == TransactionType.expense).toList();

    double total = 0.0;
    final Map<String, double> grouped = {};

    for (final t in expenses) {
      final double convertedAmount = _convertCurrency.execute(
        amount: t.amount,
        from: t.currencyCode,
        to: preferredCurrencyCode,
      );
      total += convertedAmount;
      grouped[t.categoryId] = (grouped[t.categoryId] ?? 0) + convertedAmount;
    }

    final items = grouped.entries.map((e) {
      return SpendingItemModel(
        name: _resolveCategoryName(context, e.key),
        amount: e.value,
        percentage: total == 0 ? 0 : e.value / total,
      );
    }).toList();

    return SpendingBreakdownModel(
      periodTitle: 'THIS MONTH',
      totalAmount: total,
      items: items,
    );
  }

  // FINANCIAL PULSE

  FinancialPulseModel getFinancialPulse(BuildContext context) {
    final wallet = walletViewModel.summary;
    final preferredCurrencyCode = context.currencyContext.preferredCurrencyCode;

    final txVM = context.read<TransactionViewModel>();
    final txs = txVM.state.transactions;

    double expenseTotal = 0.0;
    for (final t in txs) {
      if (t.type == TransactionType.expense) {
        final double convertedAmount = _convertCurrency.execute(
          amount: t.amount,
          from: t.currencyCode,
          to: preferredCurrencyCode,
        );
        expenseTotal += convertedAmount;
      }
    }

    final topCategoryId = _findTopCategory(txs, preferredCurrencyCode);

    return FinancialPulseModel(
      thisWeekTotal: expenseTotal / 4,
      comparePercentage: 0.0,
      isDecreased: wallet.totalAssets >= expenseTotal,
      dailySpendings: const [],
      highestDayName: '',
      highestDayAmount: expenseTotal,
      topCategoryName: _resolveCategoryName(context, topCategoryId),
      topCategoryPercentage: expenseTotal == 0 ? 0 : 100,
      aiRecommendation: _generateAdvice(wallet.totalAssets, expenseTotal),
    );
  }

  // HELPERS

  String _findTopCategory(List<TransactionEntity> txs, String preferredCurrencyCode) {
    final Map<String, double> map = {};

    for (final t in txs) {
      if (t.type != TransactionType.expense) continue;
      final double convertedAmount = _convertCurrency.execute(
        amount: t.amount,
        from: t.currencyCode,
        to: preferredCurrencyCode,
      );
      map[t.categoryId] = (map[t.categoryId] ?? 0) + convertedAmount;
    }

    if (map.isEmpty) return 'none';

    return map.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  String _generateAdvice(double assets, double expense) {
    if (assets < expense) {
      return 'Spending exceeds assets. Reduce expenses.';
    }
    return 'Financial health is stable.';
  }
}

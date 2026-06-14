import 'package:flutter/material.dart';
import 'package:spend_io_app/core/utils/transaction_grouping.dart';
import 'package:spend_io_app/features/account/domain/entities/account_entity.dart';
import 'package:spend_io_app/features/transaction/data/mock/account_transactions_mock.dart';
import 'package:spend_io_app/features/transaction/data/models/transaction_model.dart';

class AccountHeaderState {
  final AccountEntity account;
  const AccountHeaderState({required this.account});
}

class AccountFilterState {
  final String activeRangeLabel;
  final DateTimeRange? customDateRange;
  final String searchQuery;

  const AccountFilterState({
    required this.activeRangeLabel,
    this.customDateRange,
    required this.searchQuery,
  });
}

class TransactionLedgerState {
  final List<TransactionModel> allTransactions;
  final List<TransactionModel> filteredTransactions;
  final List<TransactionDayGroup> dayGroups;
  final double totalReceived;
  final double totalSpent;

  const TransactionLedgerState({
    required this.allTransactions,
    required this.filteredTransactions,
    required this.dayGroups,
    required this.totalReceived,
    required this.totalSpent,
  });
}

/// [App Location] Account feature Business Logic Layer (ViewModel).
/// [Core Function] Manages UI state pipelines for account ledger history, handling keyword search filtering, custom date range evaluation, and day grouping computation.
class AccountDetailsViewModel extends ChangeNotifier {
  AccountHeaderState? _headerState;
  AccountFilterState _filterState = const AccountFilterState(
    activeRangeLabel: 'Last 30 Days',
    searchQuery: '',
  );
  TransactionLedgerState? _ledgerState;

  AccountHeaderState? get headerState => _headerState;
  AccountFilterState get filterState => _filterState;
  TransactionLedgerState? get ledgerState => _ledgerState;

  void initialize(AccountEntity account) {
    _headerState = AccountHeaderState(account: account);

    // Load mock transactions for this account
    final mockTxs = generateMockTransactions(account.id);
    _ledgerState = TransactionLedgerState(
      allTransactions: mockTxs,
      filteredTransactions: const [],
      dayGroups: const [],
      totalReceived: 0,
      totalSpent: 0,
    );

    _updateLedger();
  }

  void setFilter(String label, {DateTimeRange? customRange}) {
    _filterState = AccountFilterState(
      activeRangeLabel: label,
      customDateRange: customRange,
      searchQuery: _filterState.searchQuery,
    );
    _updateLedger();
  }

  void setSearchQuery(String query) {
    _filterState = AccountFilterState(
      activeRangeLabel: _filterState.activeRangeLabel,
      customDateRange: _filterState.customDateRange,
      searchQuery: query,
    );
    _updateLedger();
  }

  void addTransaction(TransactionModel tx) {
    if (_ledgerState == null) {
      return;
    }

    final updatedList =
        List<TransactionModel>.from(_ledgerState!.allTransactions)..add(tx);

    _ledgerState = TransactionLedgerState(
      allTransactions: updatedList,
      filteredTransactions: _ledgerState!.filteredTransactions,
      dayGroups: _ledgerState!.dayGroups,
      totalReceived: _ledgerState!.totalReceived,
      totalSpent: _ledgerState!.totalSpent,
    );

    _updateLedger();
  }

  void _updateLedger() {
    if (_ledgerState == null || _headerState == null) {
      return;
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final List<TransactionModel> filtered =
        _ledgerState!.allTransactions.where((tx) {
      // 1. Apply Date Filter
      final txDateZero = DateTime(tx.date.year, tx.date.month, tx.date.day);
      bool matchesDate = false;

      if (_filterState.activeRangeLabel == 'Today') {
        matchesDate = txDateZero.isAtSameMomentAs(today);
      } else if (_filterState.activeRangeLabel == 'This Month') {
        matchesDate = tx.date.year == now.year && tx.date.month == now.month;
      } else if (_filterState.activeRangeLabel == 'Last Month') {
        final lastMonthYear = now.month == 1 ? now.year - 1 : now.year;
        final lastMonthVal = now.month == 1 ? 12 : now.month - 1;
        matchesDate =
            tx.date.year == lastMonthYear && tx.date.month == lastMonthVal;
      } else if (_filterState.activeRangeLabel == 'This Year') {
        matchesDate = tx.date.year == now.year;
      } else if (_filterState.activeRangeLabel == 'Custom Range...') {
        final range = _filterState.customDateRange;
        if (range != null) {
          final start =
              DateTime(range.start.year, range.start.month, range.start.day);
          final end = DateTime(
              range.end.year, range.end.month, range.end.day, 23, 59, 59);
          matchesDate =
              tx.date.isAfter(start.subtract(const Duration(seconds: 1))) &&
                  tx.date.isBefore(end.add(const Duration(seconds: 1)));
        } else {
          matchesDate = true;
        }
      } else {
        // Mặc định: Last 30 Days
        final thirtyDaysAgo = today.subtract(const Duration(days: 30));
        matchesDate = txDateZero
            .isAfter(thirtyDaysAgo.subtract(const Duration(seconds: 1)));
      }

      if (!matchesDate) {
        return false;
      }

      // 2. Apply Search Filter
      final query = _filterState.searchQuery.trim().toLowerCase();
      if (query.isEmpty) {
        return true;
      }

      final titleMatch = tx.title.toLowerCase().contains(query);
      final catMatch = tx.category.toLowerCase().contains(query);
      return titleMatch || catMatch;
    }).toList();

    // 3. Compute Sums
    double totalReceived = 0;
    double totalSpent = 0;

    for (final tx in filtered) {
      if (tx.isExpense) {
        totalSpent += tx.amount;
      } else {
        totalReceived += tx.amount;
      }
    }

    // 4. Group by Day using external utility
    final dayGroups = groupByDate(filtered);

    _ledgerState = TransactionLedgerState(
      allTransactions: _ledgerState!.allTransactions,
      filteredTransactions: filtered,
      dayGroups: dayGroups,
      totalReceived: totalReceived,
      totalSpent: totalSpent,
    );

    notifyListeners();
  }
}

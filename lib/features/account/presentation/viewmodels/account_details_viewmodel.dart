import 'package:flutter/material.dart';
import 'package:spend_io_app/core/utils/account_filter_extension.dart';
import 'package:spend_io_app/features/account/domain/entities/account_entity.dart';
import 'package:spend_io_app/features/transaction/domain/entities/transaction_entity.dart';
import 'package:spend_io_app/features/transaction/domain/entities/transaction_type.dart';

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
  final List<TransactionEntity> allTransactions;
  final List<TransactionEntity> filteredTransactions;
  final double totalReceived;
  final double totalSpent;

  const TransactionLedgerState({
    required this.allTransactions,
    required this.filteredTransactions,
    required this.totalReceived,
    required this.totalSpent,
  });
}

class AccountDetailsViewModel extends ChangeNotifier {
  AccountEntity? _account;
  AccountFilterState _filterState = const AccountFilterState(
    activeRangeLabel: 'All Time',
    searchQuery: '',
  );
  TransactionLedgerState? _ledgerState;

  AccountEntity? get account => _account;
  AccountFilterState get filterState => _filterState;
  TransactionLedgerState? get ledgerState => _ledgerState;

  void initialize(AccountEntity account, List<TransactionEntity> transactions) {
    if (_account?.id == account.id &&
        _ledgerState != null &&
        _ledgerState!.allTransactions == transactions) {
      return;
    }

    _account = account;

    _ledgerState = TransactionLedgerState(
      allTransactions: transactions,
      filteredTransactions: const [],
      totalReceived: 0,
      totalSpent: 0,
    );

    _updateLedger();
  }

  /// Cập nhật nhãn bộ lọc thời gian
  void setFilter(String label, {DateTimeRange? customRange}) {
    _filterState = AccountFilterState(
      activeRangeLabel: label,
      customDateRange: customRange,
      searchQuery: _filterState.searchQuery,
    );
    _updateLedger();
  }

  /// Cập nhật từ khóa tìm kiếm theo ô Input trên UI
  void setSearchQuery(String query) {
    _filterState = AccountFilterState(
      activeRangeLabel: _filterState.activeRangeLabel,
      customDateRange: _filterState.customDateRange,
      searchQuery: query,
    );
    _updateLedger();
  }

  void _updateLedger() {
    if (_ledgerState == null) return;

    final targetRange = _filterState.activeRangeLabel
        .toDateTimeRange(_filterState.customDateRange);

    // 1. Thực hiện lọc mảng phẳng chuẩn chỉ
    final List<TransactionEntity> filtered =
        _ledgerState!.allTransactions.where((tx) {
      if (_account != null && tx.accountId != _account!.id) {
        return false;
      }

      if (_filterState.activeRangeLabel != 'All Time' && targetRange != null) {
        if (tx.transactionDate.isBefore(targetRange.start) ||
            tx.transactionDate.isAfter(targetRange.end)) {
          return false;
        }
      }

      // Kiểm tra từ khóa tìm kiếm dựa trên trường Note của giao dịch
      final query = _filterState.searchQuery.trim().toLowerCase();
      if (query.isEmpty) return true;

      return (tx.note ?? '').toLowerCase().contains(query);
    }).toList();

    double totalReceived = 0;
    double totalSpent = 0;

    for (final tx in filtered) {
      if (tx.type == TransactionType.expense) {
        totalSpent += tx.amount;
      } else {
        totalReceived += tx.amount;
      }
    }

    _ledgerState = TransactionLedgerState(
      allTransactions: _ledgerState!.allTransactions,
      filteredTransactions: filtered,
      totalReceived: totalReceived,
      totalSpent: totalSpent,
    );

    notifyListeners();
  }
}

import 'package:flutter/material.dart';
import 'package:spend_io_app/core/utils/transaction_grouping.dart';
import 'package:spend_io_app/core/utils/account_filter_extension.dart'; // Import extension mới tách
import 'package:spend_io_app/features/account/domain/entities/account_entity.dart';
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

class AccountDetailsViewModel extends ChangeNotifier {
  AccountEntity? _originalAccount;

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
    // Lưu lại dữ liệu ban đầu làm điểm khôi phục an toàn
    _originalAccount = account;
    _headerState = AccountHeaderState(account: account);

    _ledgerState = TransactionLedgerState(
      allTransactions: [],
      filteredTransactions: const [],
      dayGroups: const [],
      totalReceived: 0,
      totalSpent: 0,
    );

    _updateLedger();
  }

  /// [Rollback Feature] Hoàn tác số dư/trạng thái ví về điểm khởi tạo ban đầu khi gặp sự cố xử lý dữ liệu
  void rollbackAccountState() {
    if (_originalAccount == null) return;
    _headerState = AccountHeaderState(account: _originalAccount!);
    _updateLedger();
  }

  /// [Init Wallet/Update Balance] Cập nhật số dư động dựa trên tác vụ nạp/rút từ các luồng giao dịch liên quan
  void updateAccountBalance(double amount, {bool isExpense = true}) {
    if (_headerState == null) return;

    final currentAccount = _headerState!.account;
    final newBalance = isExpense
        ? currentAccount.balance - amount
        : currentAccount.balance + amount;

    _headerState = AccountHeaderState(
      account: currentAccount.copyWith(balance: newBalance),
    );
    notifyListeners();
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
    if (_ledgerState == null) return;

    final updatedList =
        List<TransactionModel>.from(_ledgerState!.allTransactions)..add(tx);

    _ledgerState = TransactionLedgerState(
      allTransactions: updatedList,
      filteredTransactions: _ledgerState!.filteredTransactions,
      dayGroups: _ledgerState!.dayGroups,
      totalReceived: _ledgerState!.totalReceived,
      totalSpent: _ledgerState!.totalSpent,
    );

    // Đồng bộ trực tiếp biến động số dư vào thông tin ví hiển thị
    updateAccountBalance(tx.amount, isExpense: tx.isExpense);
    _updateLedger();
  }

  void _updateLedger() {
    if (_ledgerState == null || _headerState == null) return;

    // Lấy khoảng thời gian chuẩn hóa thông qua Extension vừa tách
    final targetRange = _filterState.activeRangeLabel
        .toDateTimeRange(_filterState.customDateRange);

    final List<TransactionModel> filtered =
        _ledgerState!.allTransactions.where((tx) {
      // 1. Kiểm tra điều kiện ngày (Lọc theo dải Range tuần tự)
      if (targetRange != null) {
        if (tx.date.isBefore(targetRange.start) ||
            tx.date.isAfter(targetRange.end)) {
          return false;
        }
      }

      // 2. Kiểm tra điều kiện từ khóa tìm kiếm (Search Query)
      final query = _filterState.searchQuery.trim().toLowerCase();
      if (query.isEmpty) return true;

      return tx.title.toLowerCase().contains(query) ||
          tx.category.toLowerCase().contains(query);
    }).toList();

    // 3. Tính toán lại tổng thu / tổng chi trong phạm vi lọc
    double totalReceived = 0;
    double totalSpent = 0;

    for (final tx in filtered) {
      if (tx.isExpense) {
        totalSpent += tx.amount;
      } else {
        totalReceived += tx.amount;
      }
    }

    // 4. Gom nhóm hiển thị theo ngày
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

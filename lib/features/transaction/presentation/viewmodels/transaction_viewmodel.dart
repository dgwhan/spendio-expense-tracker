import 'package:flutter/material.dart';
import 'package:spend_io_app/features/transaction/domain/entities/transaction_entity.dart';
import 'package:spend_io_app/features/transaction/domain/repositories/transaction_repository.dart';
import 'package:spend_io_app/features/transaction/domain/usecases/create_transaction.dart';
import 'transaction_state.dart';

class TransactionViewModel extends ChangeNotifier {
  final TransactionRepository repository;
  final CreateTransaction createTransactionUseCase;

  TransactionViewModel({
    required this.repository,
    required this.createTransactionUseCase,
  });

  TransactionState _state = const TransactionState();
  TransactionState get state => _state;
  String? _currentAccountId;

  /// Tải danh sách giao dịch scoped theo từng ví tài khoản lẻ
  Future<void> loadByAccount(String accountId) async {
    _currentAccountId = accountId;
    _setState(_state.copyWith(isLoading: true, error: null));
    try {
      final data = await repository.getTransactionsByAccount(accountId);
      _setState(_state.copyWith(isLoading: false, transactions: data));
    } catch (e) {
      _setState(_state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  /// Thêm mới một bản ghi giao dịch (Chạy qua UseCase để xử lý lưu & đồng bộ)
  Future<void> addTransaction(TransactionEntity entity) async {
    debugPrint('[TransactionVM] addTransaction called: ${entity.id}');
    try {
      await createTransactionUseCase(entity);
      debugPrint('[TransactionVM] createTransactionUseCase completed');
      if (_currentAccountId != null) await loadByAccount(_currentAccountId!);
    } catch (e) {
      debugPrint('[TransactionVM] addTransaction error: $e');
      _setState(_state.copyWith(error: e.toString()));
    }
  }

  /// Cập nhật giao dịch cũ sang giao dịch mới (So sánh song song 2 trạng thái cũ/mới)
  Future<void> updateTransaction({
    required TransactionEntity newEntity,
    required TransactionEntity oldEntity,
  }) async {
    try {
      // Gọi thông qua Repository đã được wrap bộ tinh toán UpdateWalletBalance ở Step 02
      await repository.updateTransaction(
        newTransaction: newEntity,
        oldTransaction: oldEntity,
      );
      if (_currentAccountId != null) await loadByAccount(_currentAccountId!);
    } catch (e) {
      _setState(_state.copyWith(error: e.toString()));
    }
  }

  /// Xóa vật lý giao dịch (Nhận nguyên Entity để hoàn tác số dư chính xác)
  Future<void> deleteTransaction(TransactionEntity entity) async {
    try {
      // Gọi repository xử lý Hard Delete + Rollback Balance tổng sản nghiệp
      await repository.deleteTransaction(entity);
      if (_currentAccountId != null) await loadByAccount(_currentAccountId!);
    } catch (e) {
      _setState(_state.copyWith(error: e.toString()));
    }
  }

  /// Dọn sạch State giao dịch khi Logout hệ thống
  void clearTransactions() {
    _setState(const TransactionState());
  }

  void _setState(TransactionState newState) {
    _state = newState;
    notifyListeners();
  }
}

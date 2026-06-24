import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
  int? _userId;

  int? get userId => _userId;

  void updateUserId(int? userId) {
    if (_userId == userId) return;
    _userId = userId;
    if (userId != null) {
      loadAllTransactions();
    }
  }

  // Callback duoc DI lop ngoai gan vao, dung de bao cho module Budget
  // tinh lai progress moi khi so du giao dich thay doi. TransactionViewModel
  // khong import truc tiep BudgetViewModel de giu tach biet tang feature.
  Future<void> Function(int userId)? onTransactionBalanceChanged;

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

  Future<void> loadAllTransactions() async {
    if (_userId == null) {
      debugPrint('[TransactionVM]: loadAllTransactions aborted. No active userId found.');
      return;
    }
    _currentAccountId = null;
    _setState(_state.copyWith(isLoading: true, error: null));

    try {
      final data = await repository.getAllTransactions(_userId!);
      _setState(_state.copyWith(isLoading: false, transactions: data));
    } catch (e) {
      _setState(_state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> addTransaction(TransactionEntity entity) async {
    debugPrint('[TransactionVM] addTransaction called: ${entity.id}');

    TransactionEntity finalEntity = entity;
    if (entity.note == null || entity.note!.trim().isEmpty) {
      finalEntity = entity.copyWith(
        note: _generateDefaultNote(entity.transactionDate),
      );
    }

    try {
      await createTransactionUseCase(finalEntity);
      debugPrint('[TransactionVM] createTransactionUseCase completed');
      await _notifyBudgetBalanceChanged(finalEntity.userId);
    } catch (e, stackTrace) {
      debugPrint('[TransactionVM] addTransaction error: $e');
      debugPrintStack(stackTrace: stackTrace);
      _setState(_state.copyWith(error: e.toString()));
    } finally {
      if (_currentAccountId != null) {
        await loadByAccount(_currentAccountId!);
      } else {
        await loadAllTransactions();
      }
    }
  }

  Future<void> updateTransaction({
    required TransactionEntity newEntity,
    required TransactionEntity oldEntity,
  }) async {
    TransactionEntity finalNewEntity = newEntity;
    if (newEntity.note == null || newEntity.note!.trim().isEmpty) {
      finalNewEntity = newEntity.copyWith(
        note: _generateDefaultNote(newEntity.transactionDate),
      );
    }

    try {
      await repository.updateTransaction(
        newTransaction: finalNewEntity,
        oldTransaction: oldEntity,
      );
      await _notifyBudgetBalanceChanged(finalNewEntity.userId);
    } catch (e, stackTrace) {
      debugPrint('[TransactionVM] updateTransaction error: $e');
      debugPrintStack(stackTrace: stackTrace);
      _setState(_state.copyWith(error: e.toString()));
    } finally {
      if (_currentAccountId != null) {
        await loadByAccount(_currentAccountId!);
      } else {
        await loadAllTransactions();
      }
    }
  }

  Future<void> deleteTransaction(TransactionEntity entity) async {
    try {
      await repository.deleteTransaction(entity);
      await _notifyBudgetBalanceChanged(entity.userId);
    } catch (e, stackTrace) {
      debugPrint('[TransactionVM] deleteTransaction error: $e');
      debugPrintStack(stackTrace: stackTrace);
      _setState(_state.copyWith(error: e.toString()));
    } finally {
      if (_currentAccountId != null) {
        await loadByAccount(_currentAccountId!);
      } else {
        await loadAllTransactions();
      }
    }
  }

  Future<void> _notifyBudgetBalanceChanged(int userId) async {
    if (onTransactionBalanceChanged == null) return;
    try {
      await onTransactionBalanceChanged!(userId);
    } catch (e) {
      debugPrint('[TransactionVM] onTransactionBalanceChanged error: $e');
    }
  }

  void clearTransactions() {
    _setState(const TransactionState());
  }

  void _setState(TransactionState newState) {
    _state = newState;
    notifyListeners();
  }

  // Neu nguoi dung khong nhap note thi luu note mac dinh theo ngay giao dich
  String _generateDefaultNote(DateTime date) {
    final dateFormat = DateFormat('dd/MM/yyyy').format(date);
    return 'Transaction $dateFormat';
  }
}

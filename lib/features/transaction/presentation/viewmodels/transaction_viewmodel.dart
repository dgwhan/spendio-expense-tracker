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

  Future<void> loadByAccount(String accountId) async {
    _currentAccountId = accountId;

    _setState(
      _state.copyWith(
        isLoading: true,
        error: null,
      ),
    );

    try {
      final data = await repository.getTransactionsByAccount(
        accountId,
      );

      _setState(
        _state.copyWith(
          isLoading: false,
          transactions: data,
        ),
      );
    } catch (e) {
      _setState(
        _state.copyWith(
          isLoading: false,
          error: e.toString(),
        ),
      );
    }
  }

  Future<void> addTransaction(
    TransactionEntity entity,
  ) async {
    debugPrint(
      '[TransactionVM] addTransaction called: ${entity.id}',
    );

    try {
      await createTransactionUseCase(
        entity,
      );

      debugPrint(
        '[TransactionVM] createTransactionUseCase completed',
      );
    } catch (e, stackTrace) {
      debugPrint(
        '[TransactionVM] addTransaction error: $e',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      _setState(
        _state.copyWith(
          error: e.toString(),
        ),
      );
    } finally {
      if (_currentAccountId != null) {
        await loadByAccount(
          _currentAccountId!,
        );
      }
    }
  }

  Future<void> updateTransaction({
    required TransactionEntity newEntity,
    required TransactionEntity oldEntity,
  }) async {
    try {
      await repository.updateTransaction(
        newTransaction: newEntity,
        oldTransaction: oldEntity,
      );
    } catch (e, stackTrace) {
      debugPrint(
        '[TransactionVM] updateTransaction error: $e',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      _setState(
        _state.copyWith(
          error: e.toString(),
        ),
      );
    } finally {
      if (_currentAccountId != null) {
        await loadByAccount(
          _currentAccountId!,
        );
      }
    }
  }

  Future<void> deleteTransaction(
    TransactionEntity entity,
  ) async {
    try {
      await repository.deleteTransaction(
        entity,
      );
    } catch (e, stackTrace) {
      debugPrint(
        '[TransactionVM] deleteTransaction error: $e',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      _setState(
        _state.copyWith(
          error: e.toString(),
        ),
      );
    } finally {
      if (_currentAccountId != null) {
        await loadByAccount(
          _currentAccountId!,
        );
      }
    }
  }

  void clearTransactions() {
    _setState(
      const TransactionState(),
    );
  }

  void _setState(
    TransactionState newState,
  ) {
    _state = newState;
    notifyListeners();
  }
}

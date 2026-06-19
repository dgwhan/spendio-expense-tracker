import 'package:flutter/foundation.dart';

import 'package:spend_io_app/features/budget/domain/entities/monthly/budget_entity.dart';
import 'package:spend_io_app/features/budget/domain/entities/monthly/budget_progress_entity.dart';

import 'package:spend_io_app/features/budget/domain/repositories/budget_repository.dart';
import 'package:spend_io_app/features/budget/domain/services/budget_progress_calculator.dart';

class BudgetViewModel extends ChangeNotifier {
  final BudgetRepository _repository;
  final BudgetProgressCalculator _calculator;

  BudgetViewModel({
    required BudgetRepository repository,
    required BudgetProgressCalculator calculator,
  })  : _repository = repository,
        _calculator = calculator;

  // =========================================================
  // STATE
  // =========================================================

  BudgetProgressEntity? _currentBudget;
  BudgetProgressEntity? get currentBudget => _currentBudget;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  int _requestId = 0;
  bool _disposed = false;

  // =========================================================
  // LOAD
  // =========================================================

  Future<void> loadBudget(int userId) async {
    final request = ++_requestId;

    _isLoading = true;
    _safeNotify();

    try {
      final budget = await _repository.getCurrentBudget(userId);

      if (_disposed || request != _requestId) return;

      if (budget == null) {
        _currentBudget = null;
        return;
      }

      final result = await _calculator.calculateBudgetProgress(
        budget,
      );

      if (_disposed || request != _requestId) return;

      _currentBudget = result;
    } finally {
      if (!_disposed && request == _requestId) {
        _isLoading = false;
        _safeNotify();
      }
    }
  }

  // =========================================================
  // CREATE
  // =========================================================

  Future<void> createBudget(
    BudgetEntity budget,
  ) async {
    await _repository.createBudget(
      budget,
    );

    await loadBudget(
      budget.userId,
    );
  }

  // =========================================================
  // UPDATE
  // =========================================================

  Future<void> updateBudget(
    BudgetEntity budget,
  ) async {
    await _repository.updateBudget(
      budget,
    );

    await loadBudget(
      budget.userId,
    );
  }

  // =========================================================
  // DELETE
  // =========================================================

  Future<void> deleteBudget({
    required String budgetId,
    required int userId,
  }) async {
    await _repository.deleteBudget(
      budgetId,
    );

    await loadBudget(
      userId,
    );
  }

  // =========================================================
  // HELPERS
  // =========================================================

  void clear() {
    _currentBudget = null;
    _safeNotify();
  }

  void _safeNotify() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}

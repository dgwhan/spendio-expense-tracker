import 'package:flutter/foundation.dart';
import 'package:spend_io_app/features/budget/domain/entities/budget_entity.dart';
import 'package:spend_io_app/features/budget/domain/entities/budget_progress_entity.dart';
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

  BudgetProgressEntity? _currentBudget;
  BudgetProgressEntity? get currentBudget => _currentBudget;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  int _requestId = 0;
  bool _disposed = false;

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

      final result = await _calculator.calculateBudgetProgress(budget);

      if (_disposed || request != _requestId) return;

      _currentBudget = result;
    } finally {
      if (!_disposed && request == _requestId) {
        _isLoading = false;
        _safeNotify();
      }
    }
  }

  Future<void> createBudget(BudgetEntity budget) async {
    await _repository.createBudget(budget);
    await loadBudget(budget.userId);
  }

  Future<void> updateBudget(BudgetEntity budget) async {
    await _repository.updateBudget(budget);
    await loadBudget(budget.userId);
  }

  Future<void> deleteBudget({
    required String budgetId,
    required int userId,
  }) async {
    try {
      await _repository.deleteBudget(
        budgetId: budgetId,
        userId: userId,
      );

      await loadBudget(userId);
    } catch (e) {
      rethrow;
    }
  }

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

import 'package:flutter/material.dart';
import 'package:spend_io_app/features/budget/domain/entities/budget_category_entity.dart';
import 'package:spend_io_app/features/budget/domain/entities/budget_category_progress_entity.dart';
import 'package:spend_io_app/features/budget/domain/entities/budget_state.dart';
import 'package:spend_io_app/features/budget/domain/services/budget_progress_calculator.dart';
import 'package:spend_io_app/features/budget/domain/repositories/budget_repository.dart';

class BudgetCategoryViewModel extends ChangeNotifier {
  final BudgetRepository _repository;
  final BudgetProgressCalculator _calculator;

  BudgetCategoryViewModel({
    required BudgetRepository repository,
    required BudgetProgressCalculator calculator,
  })  : _repository = repository,
        _calculator = calculator;

  // ================= STATE =================
  List<BudgetCategoryProgressEntity> _categoryProgressList = [];
  List<BudgetCategoryProgressEntity> get categoryProgressList =>
      List.unmodifiable(_categoryProgressList);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  int _requestId = 0;
  bool _disposed = false;

  // ================= READ =================
  Future<void> loadCategoriesProgress(BudgetState state) async {
    final int request = ++_requestId;

    _isLoading = true;
    _safeNotify();

    try {
      final result = await _calculator.calculateCategoryProgressList(
        budgetId: state.budget.id,
        startDate: state.budget.startDate,
        endDate: state.budget.endDate,
      );

      if (_disposed || request != _requestId) return;

      _categoryProgressList = result;
    } finally {
      if (!_disposed && request == _requestId) {
        _isLoading = false;
        _safeNotify();
      }
    }
  }

  // ================= CREATE =================
  Future<void> createCategory({
    required BudgetCategoryEntity category,
    required BudgetState state,
  }) async {
    await _repository.createBudgetCategory(category);
    await loadCategoriesProgress(state);
  }

  // ================= UPDATE =================
  Future<void> updateCategory({
    required BudgetCategoryEntity category,
    required BudgetState state,
  }) async {
    await _repository.updateBudgetCategory(category);
    await loadCategoriesProgress(state);
  }

  // ================= DELETE =================
  Future<void> deleteCategory({
    required String id,
    required BudgetState state,
  }) async {
    await _repository.deleteBudgetCategory(id);
    await loadCategoriesProgress(state);
  }

  // ================= SAFE NOTIFY =================
  void _safeNotify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}

import 'package:flutter/material.dart';

import 'package:spend_io_app/features/budget/domain/entities/budget_category_entity.dart';
import 'package:spend_io_app/features/budget/domain/entities/budget_category_progress_entity.dart';
import 'package:spend_io_app/features/budget/domain/repositories/budget_repository.dart';
import 'package:spend_io_app/features/budget/domain/services/budget_progress_calculator.dart';

class BudgetCategoryViewModel extends ChangeNotifier {
  final BudgetRepository _repository;
  final BudgetProgressCalculator _calculator;

  BudgetCategoryViewModel({
    required BudgetRepository repository,
    required BudgetProgressCalculator calculator,
  })  : _repository = repository,
        _calculator = calculator;

  // state

  List<BudgetCategoryEntity> _categories = [];
  List<BudgetCategoryEntity> get categories => List.unmodifiable(_categories);

  List<BudgetCategoryProgressEntity> _progressList = [];
  List<BudgetCategoryProgressEntity> get progressList =>
      List.unmodifiable(_progressList);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  int _requestId = 0;
  bool _disposed = false;

  // load categories

  Future<void> loadCategories(
    int userId,
  ) async {
    _categories = await _repository.getBudgetCategories(
      userId,
    );

    _safeNotify();
  }

  // load progress

  Future<void> loadProgress(
    int userId,
  ) async {
    final request = ++_requestId;

    _isLoading = true;
    _safeNotify();

    try {
      final result = await _calculator.calculateCategoryProgressList(
        userId: userId,
      );

      if (_disposed || request != _requestId) return;

      _progressList = result;
    } finally {
      if (!_disposed && request == _requestId) {
        _isLoading = false;
        _safeNotify();
      }
    }
  }

  // create

  Future<void> createCategory(
    BudgetCategoryEntity category,
  ) async {
    await _repository.createBudgetCategory(
      category,
    );

    await loadCategories(
      category.userId,
    );

    await loadProgress(
      category.userId,
    );
  }

  // update

  Future<void> updateCategory(
    BudgetCategoryEntity category,
  ) async {
    await _repository.updateBudgetCategory(
      category,
    );

    await loadCategories(
      category.userId,
    );

    await loadProgress(
      category.userId,
    );
  }

  // delete

  Future<void> deleteCategory({
    required String id,
    required int userId,
  }) async {
    await _repository.deleteBudgetCategory(
      id,
    );

    await loadCategories(
      userId,
    );

    await loadProgress(
      userId,
    );
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

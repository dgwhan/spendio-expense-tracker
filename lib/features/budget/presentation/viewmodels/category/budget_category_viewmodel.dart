import 'package:flutter/material.dart';
import 'package:spend_io_app/features/budget/domain/entities/category/budget_category_entity.dart';
import 'package:spend_io_app/features/budget/domain/entities/category/budget_category_progress_entity.dart';
import 'package:spend_io_app/features/budget/domain/services/budget_progress_calculator.dart';
import 'package:spend_io_app/features/budget/domain/usecase/category/create_budget_category_usecase.dart';
import 'package:spend_io_app/features/budget/domain/usecase/category/delete_budget_category_usecase.dart';
import 'package:spend_io_app/features/budget/domain/usecase/category/get_budget_categories_usecase.dart';
import 'package:spend_io_app/features/budget/domain/usecase/category/update_budget_category_usecase.dart';

class BudgetCategoryViewModel extends ChangeNotifier {
  final CreateBudgetCategoryUseCase _createUseCase;
  final GetBudgetCategoriesUseCase _getUseCase;
  final UpdateBudgetCategoryUseCase _updateUseCase;
  final DeleteBudgetCategoryUseCase _deleteUseCase;
  final BudgetProgressCalculator _calculator;

  BudgetCategoryViewModel({
    required CreateBudgetCategoryUseCase createUseCase,
    required GetBudgetCategoriesUseCase getUseCase,
    required UpdateBudgetCategoryUseCase updateUseCase,
    required DeleteBudgetCategoryUseCase deleteUseCase,
    required BudgetProgressCalculator calculator,
  })  : _createUseCase = createUseCase,
        _getUseCase = getUseCase,
        _updateUseCase = updateUseCase,
        _deleteUseCase = deleteUseCase,
        _calculator = calculator;

  // ================= STATE =================
  List<BudgetCategoryEntity> _categories = [];
  List<BudgetCategoryEntity> get categories => List.unmodifiable(_categories);

  List<BudgetCategoryProgressEntity> _progressList = [];
  List<BudgetCategoryProgressEntity> get progressList =>
      List.unmodifiable(_progressList);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  int _requestId = 0;
  bool _disposed = false;

  // ================= LOAD BASE DATA =================
  Future<void> loadCategories(int userId) async {
    final data = await _getUseCase(userId);
    _categories = data;
    _safeNotify();
  }

  // ================= LOAD PROGRESS =================
  Future<void> loadProgress(int userId) async {
    final request = ++_requestId;

    _isLoading = true;
    _safeNotify();

    try {
      final result =
          await _calculator.calculateCategoryProgressList(userId: userId);

      if (_disposed || request != _requestId) return;

      _progressList = result;
    } finally {
      if (!_disposed && request == _requestId) {
        _isLoading = false;
        _safeNotify();
      }
    }
  }

  // ================= CRUD INTERACTION =================
  Future<void> createCategory(BudgetCategoryEntity category) async {
    await _createUseCase(category);
    await _refresh(category.userId);
  }

  Future<void> updateCategory(BudgetCategoryEntity category) async {
    await _updateUseCase(category);
    await _refresh(category.userId);
  }

  // ================= CRUD INTERACTION =================
  Future<bool> deleteCategory({
    required String id,
    required int userId,
  }) async {
    _isLoading = true;
    _safeNotify();

    try {
      await _deleteUseCase(id);
      await _refresh(userId);
      return true;
    } catch (e) {
      debugPrint('[BUDGET CATEGORY VM ERROR] Delete failed: $e');
      return false;
    } finally {
      _isLoading = false;
      _safeNotify();
    }
  }

  // ================= INTERNAL REFRESH =================
  Future<void> _refresh(int userId) async {
    await loadCategories(userId);
    await loadProgress(userId);
  }

  void _safeNotify() {
    if (!_disposed) notifyListeners();
  }

  void clear() {
    _categories = [];
    _progressList = [];
    _safeNotify();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}

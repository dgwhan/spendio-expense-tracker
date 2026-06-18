import 'package:flutter/material.dart';
import 'package:spend_io_app/features/budget/domain/entities/budget_entity.dart';
import 'package:spend_io_app/features/budget/domain/entities/budget_state.dart';
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

  // ================= STATE =================
  BudgetState? _currentBudget;
  BudgetState? get currentBudget => _currentBudget;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  int _requestId = 0;
  bool _disposed = false;

  // ================= READ =================
  Future<void> loadBudget(int userId) async {
    final int request = ++_requestId;

    _isLoading = true;
    _safeNotify();

    try {
      final budget = await _repository.getCurrentBudget(userId);

      //Check stale request hoặc null trước khi tính
      if (budget == null || _disposed || request != _requestId) {
        if (budget == null && request == _requestId) {
          _currentBudget = null;
        }
        return;
      }

      // Chỉ kích hoạt engine tính toán nặng khi request này vẫn là mới nhất
      final result = await _calculator.calculateBudgetProgress(budget);

      // Check lại lần nữa phòng trường hợp user click quá nhanh trong lúc calculator đang chạy
      if (_disposed || request != _requestId) return;

      _currentBudget = result;
    } finally {
      // KHÔNG CẦN CHECK DUPLICATE: Giao toàn bộ trách nhiệm kiểm tra cho _safeNotify quản lý
      if (request == _requestId) {
        _isLoading = false;
        _safeNotify();
      }
    }
  }

  // ================= CREATE =================
  Future<void> createBudget(BudgetEntity budget) async {
    try {
      await _repository.createBudget(budget);
      await loadBudget(budget.userId);
    } catch (e) {
      debugPrint('[BudgetViewModel] Create budget failed: $e');
    }
  }

  // ================= SAFE NOTIFY CENTRALIZED =================
  // Đóng vai trò là chốt chặn an toàn, loại bỏ việc check '!_disposed' thủ công ở tầng trên
  void _safeNotify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}

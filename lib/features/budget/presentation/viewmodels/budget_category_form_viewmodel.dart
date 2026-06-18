import 'package:flutter/material.dart';
import 'package:spend_io_app/features/budget/domain/entities/budget_state.dart';

class BudgetCategoryFormViewModel extends ChangeNotifier {
  String? _selectedCategoryId;
  double _amount = 0.0;
  String? _errorMessage;

  String? get selectedCategoryId => _selectedCategoryId;
  double get amount => _amount;
  String? get errorMessage => _errorMessage;

  void updateCategory(String? categoryId, BudgetState currentBudgetState) {
    _selectedCategoryId = categoryId;
    _validate(currentBudgetState);
  }

  void updateAmount(String val, BudgetState currentBudgetState) {
    _amount = double.tryParse(val) ?? 0.0;
    _validate(currentBudgetState);
  }

  bool _validate(BudgetState currentBudgetState) {
    if (_selectedCategoryId == null || _selectedCategoryId!.isEmpty) {
      _errorMessage = 'Vui lòng chọn danh mục';
      notifyListeners();
      return false;
    }
    if (_amount <= 0) {
      _errorMessage = 'Số tiền ngân sách danh mục phải lớn hơn 0';
      notifyListeners();
      return false;
    }

    // Kiểm tra business logic đặc thù: Tổng budget con không được vượt quá budget cha
    if (_amount > currentBudgetState.budget.amount) {
      _errorMessage =
          'Ngân sách danh mục không thể vượt quá tổng ngân sách tháng';
      notifyListeners();
      return false;
    }

    _errorMessage = null;
    notifyListeners();
    return true;
  }

  bool isSubmittable(BudgetState currentBudgetState) =>
      _validate(currentBudgetState) && _errorMessage == null;

  void reset() {
    _selectedCategoryId = null;
    _amount = 0.0;
    _errorMessage = null;
  }
}

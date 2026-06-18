import 'package:flutter/material.dart';
import 'package:spend_io_app/features/budget/domain/entities/budget_progress_entity.dart';

class BudgetCategoryFormViewModel extends ChangeNotifier {
  String? _selectedCategoryId;
  double _amount = 0.0;
  String? _errorMessage;

  String? get selectedCategoryId => _selectedCategoryId;
  double get amount => _amount;
  String? get errorMessage => _errorMessage;

  void updateCategory(String? categoryId, BudgetProgressEntity currentBudgetProgressEntity) {
    _selectedCategoryId = categoryId;
    _validate(currentBudgetProgressEntity);
  }

  void updateAmount(String val, BudgetProgressEntity currentBudgetProgressEntity) {
    _amount = double.tryParse(val) ?? 0.0;
    _validate(currentBudgetProgressEntity);
  }

  bool _validate(BudgetProgressEntity currentBudgetProgressEntity) {
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
    if (_amount > currentBudgetProgressEntity.budget.amount) {
      _errorMessage =
          'Ngân sách danh mục không thể vượt quá tổng ngân sách tháng';
      notifyListeners();
      return false;
    }

    _errorMessage = null;
    notifyListeners();
    return true;
  }

  bool isSubmittable(BudgetProgressEntity currentBudgetProgressEntity) =>
      _validate(currentBudgetProgressEntity) && _errorMessage == null;

  void reset() {
    _selectedCategoryId = null;
    _amount = 0.0;
    _errorMessage = null;
  }
}

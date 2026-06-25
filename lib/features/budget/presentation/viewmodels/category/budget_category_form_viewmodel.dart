import 'package:flutter/material.dart';
import 'package:spend_io_app/features/budget/domain/entities/category/budget_category_entity.dart';
import 'package:spend_io_app/features/budget/domain/entities/budget_period.dart';
import 'package:spend_io_app/features/budget/presentation/viewmodels/category/budget_category_viewmodel.dart';
import 'package:spend_io_app/features/category/domain/entities/category_entity.dart';

class BudgetCategoryFormViewModel extends ChangeNotifier {
  final _formKey = GlobalKey<FormState>();
  GlobalKey<FormState> get formKey => _formKey;

  String _amount = '';
  CategoryEntity? _selectedCategory;
  bool _isSubmitting = false;
  BudgetCategoryEntity? _editingCategoryBudget;

  bool get isSubmitting => _isSubmitting;
  CategoryEntity? get selectedCategory => _selectedCategory;
  bool get isEditMode => _editingCategoryBudget != null;
  BudgetCategoryEntity? get editingCategoryBudget => _editingCategoryBudget;
  String get amount => _amount;

  void setAmount(String value) {
    _amount = value.replaceAll(RegExp(r'[^\d]'), '');
  }

  void setCategory(CategoryEntity? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setupEditMode(
      BudgetCategoryEntity budgetCategory, CategoryEntity categoryDetails) {
    _editingCategoryBudget = budgetCategory;
    _amount = budgetCategory.amount.toStringAsFixed(0);
    _selectedCategory = categoryDetails;
    notifyListeners();
  }

  void resetForm() {
    _amount = '';
    _selectedCategory = null;
    _editingCategoryBudget = null;
    _isSubmitting = false;
  }

  String? validateAmount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter an amount';
    }
    final cleanValue = value.replaceAll(RegExp(r'[^\d]'), '');
    final numValue = double.tryParse(cleanValue);
    if (numValue == null || numValue <= 0) {
      return 'Please enter a valid amount greater than 0';
    }
    if (numValue > 999999999) {
      return 'Amount cannot exceed 999.999.999';
    }
    return null;
  }

  DateTime _startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 0, 0, 0, 0);
  }

  DateTime _endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
  }

  Future<bool> submitCategoryBudget({
    required BudgetCategoryViewModel categoryVM,
    required int userId,
    required String currencyCode,
  }) async {
    if (_formKey.currentState == null ||
        !_formKey.currentState!.validate() ||
        _selectedCategory == null) {
      return false;
    }

    _formKey.currentState!.save();
    _isSubmitting = true;
    notifyListeners();

    try {
      final now = DateTime.now();
      final cleanAmountStr = _amount.replaceAll(RegExp(r'[^\d]'), '');
      final parsedAmount =
          double.parse(cleanAmountStr.isEmpty ? '0' : cleanAmountStr);

      if (isEditMode) {
        final updated = _editingCategoryBudget!.copyWith(
          categoryId: _selectedCategory!.id,
          name: _selectedCategory!.name,
          amount: parsedAmount,
          updatedAt: now,
        );
        await categoryVM.updateCategory(updated);
      } else {
        final startDate = _startOfDay(DateTime(now.year, now.month, 1));
        final endDate = _endOfDay(DateTime(now.year, now.month + 1, 0));

        final newCategoryBudget = BudgetCategoryEntity(
          id: UniqueKey().toString(),
          userId: userId,
          categoryId: _selectedCategory!.id,
          name: _selectedCategory!.name,
          amount: parsedAmount,
          currencyCode: currencyCode,
          periodType: BudgetPeriod.monthly,
          startDate: startDate,
          endDate: endDate,
          createdAt: now,
          updatedAt: now,
        );
        await categoryVM.createCategory(newCategoryBudget);
      }
      return true;
    } catch (e) {
      debugPrint('[BUDGET CATEGORY FORM ERROR] Submit failed: $e');
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }
}

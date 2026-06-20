import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:spend_io_app/features/budget/domain/entities/budget_entity.dart';
import 'package:spend_io_app/features/budget/domain/entities/budget_period.dart';
import 'package:spend_io_app/features/budget/domain/usecase/monthly/delete_budget_usecase.dart';
import 'package:spend_io_app/features/budget/domain/usecase/monthly/update_budget_usecase.dart';
import 'package:spend_io_app/features/budget/presentation/viewmodels/monthly/budget_viewmodel.dart';

class BudgetFormViewModel extends ChangeNotifier {
  final _formKey = GlobalKey<FormState>();
  GlobalKey<FormState> get formKey => _formKey;

  String _amount = '';
  bool _isSubmitting = false;
  BudgetEntity?
      _editingBudget; // Lưu trữ thực thể ngân sách cũ khi ở chế độ sửa

  bool get isSubmitting => _isSubmitting;
  bool get isEditMode => _editingBudget != null;

  void setAmount(String value) {
    _amount = value.replaceAll(RegExp(r'[^\d]'), '');
  }

  // Khởi động chế độ Edit: Nạp dữ liệu cũ lên giao diện điền form
  void setupEditMode(BudgetEntity budget) {
    _editingBudget = budget;
    _amount = budget.amount.toStringAsFixed(0);
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
    return null;
  }

  // Chuẩn hóa mốc thời gian đầu kỳ về 00:00:00.000 trong cùng múi giờ local
  DateTime _startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 0, 0, 0, 0);
  }

  // Chuẩn hóa mốc thời gian cuối kỳ về 23:59:59.999 trong cùng múi giờ local
  DateTime _endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
  }

  Future<bool> submitBudget({
    required BudgetViewModel budgetVM,
    required UpdateBudgetUseCase updateBudgetUseCase,
    required int userId,
  }) async {
    if (!_formKey.currentState!.validate()) {
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
        // EDIT
        final updatedBudget = _editingBudget!.copyWith(
          amount: parsedAmount,
          updatedAt: now,
        );

        debugPrint(
            '[BUDGET FORM EDIT] Updating budget: ${updatedBudget.id} with amount: $parsedAmount');
        await updateBudgetUseCase(userId: userId, budget: updatedBudget);
      } else {
        //CREATE
        final startDate = _startOfDay(DateTime(now.year, now.month, 1));
        final endDate = _endOfDay(DateTime(now.year, now.month + 1, 0));
        final autoBudgetName =
            '${DateFormat('MMMM').format(now)} ${now.year} Budget';

        final newBudget = BudgetEntity(
          id: UniqueKey().toString(),
          userId: userId,
          name: autoBudgetName,
          amount: parsedAmount,
          periodType: BudgetPeriod.monthly,
          startDate: startDate,
          endDate: endDate,
          createdAt: now,
          updatedAt: now,
        );

        debugPrint(
            '[BUDGET FORM CREATE] startDate=${startDate.toIso8601String()} endDate=${endDate.toIso8601String()}');
        await budgetVM.createBudget(newBudget);
      }

      return true;
    } catch (e) {
      debugPrint('[BUDGET FORM ERROR] Action failed: $e');
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<bool> deleteBudget({
    required DeleteBudgetUseCase deleteUseCase,
    required int userId,
  }) async {
    if (_editingBudget == null) return false;

    _isSubmitting = true;
    notifyListeners();

    try {
      await deleteUseCase(userId: userId, budgetId: _editingBudget!.id);
      return true;
    } catch (e) {
      debugPrint('[BUDGET FORM ERROR] Cannot delete budget: $e');
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }
}

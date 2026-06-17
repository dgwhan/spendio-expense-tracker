import 'package:flutter/material.dart';
import 'package:spend_io_app/features/category/domain/entities/category_entity.dart';
import 'package:spend_io_app/features/category/domain/repositories/category_repository.dart';
import 'package:spend_io_app/features/category/presentation/viewmodels/category_state.dart';

class CategoryViewModel extends ChangeNotifier {
  CategoryRepository _repository;

  CategoryViewModel({required CategoryRepository repository})
      : _repository = repository;

  void updateRepository(CategoryRepository newRepository) {
    _repository = newRepository;
  }

  CategoryState _state = const CategoryState();
  CategoryState get state => _state;

  Future<void> loadCategories(int localUserId) async {
    _state = _state.copyWith(isLoading: true, error: null);
    notifyListeners();

    try {
      final data = await _repository.getCategories(localUserId);
      _state = _state.copyWith(isLoading: false, categories: data);
    } catch (e) {
      _state = _state.copyWith(isLoading: false, error: e.toString());
    }
    notifyListeners();
  }

  Future<String?> deleteCategory({
    required String categoryId,
    required String remoteUid,
    required int userId,
  }) async {
    try {
      await _repository.deleteCategory(categoryId, remoteUid);

      await loadCategories(userId);

      return null;
    } catch (e) {
      return e.toString().replaceAll('Exception: ', '');
    }
  }

  Future<String?> createCustomCategory({
    required CategoryEntity category,
    required String remoteUid,
    required int userId,
  }) async {
    try {
      // 1. Thực thi tạo thông qua Repository ẩn dưới Data layer
      await _repository.createCustomCategory(category, remoteUid);

      // 2. Kéo dữ liệu mới nhất về RAM cache ngay lập tức để cập nhật State
      await loadCategories(userId);

      return null; // Thành công mỹ mãn
    } catch (e) {
      return e.toString().replaceAll('Exception: ', ''); // Trả về thông báo lỗi
    }
  }

  /// ================= EXPENSE FLOW LOGIC =================

  /// Filters all categories belonging to the expense flow
  List<CategoryEntity> get expenseCategories =>
      _state.categories.where((c) => c.type == 'expense').toList();

  /// Groups expense categories by their fixed group name for Section Views
  Map<String, List<CategoryEntity>> get groupedExpenseCategories {
    final Map<String, List<CategoryEntity>> groups = {};
    for (final category in expenseCategories) {
      groups.putIfAbsent(category.groupName, () => []).add(category);
    }
    return groups;
  }

  /// ================= INCOME FLOW LOGIC =================

  /// Filters all categories belonging to the income flow
  List<CategoryEntity> get incomeCategories =>
      _state.categories.where((c) => c.type == 'income').toList();

  /// Groups income categories by their fixed group name for Section Views
  Map<String, List<CategoryEntity>> get groupedIncomeCategories {
    final Map<String, List<CategoryEntity>> groups = {};
    for (final category in incomeCategories) {
      groups.putIfAbsent(category.groupName, () => []).add(category);
    }
    return groups;
  }
}

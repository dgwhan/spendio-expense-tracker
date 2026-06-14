import 'package:spend_io_app/features/wallet/domain/entities/budget_category_entity.dart';

abstract class BudgetCategoryRepository {
  /// Lấy danh sách danh mục ngân sách của người dùng
  Future<List<BudgetCategoryEntity>> getCategories(int localUserId);

  /// Tạo danh mục ngân sách mới
  Future<void> createCategory(int localUserId, BudgetCategoryEntity category);

  /// Cập nhật danh mục ngân sách
  Future<void> updateCategory(int localUserId, BudgetCategoryEntity category);

  Future<bool> hasCategories(int userId);
}

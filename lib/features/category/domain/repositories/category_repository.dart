import 'package:spend_io_app/features/category/domain/entities/category_entity.dart';

abstract class CategoryRepository {
  /// Fetches all system defaults and user-created categories combined
  Future<List<CategoryEntity>> getCategories(int localUserId);

  /// Creates a custom category scoped to a specific user
  Future<void> createCustomCategory(CategoryEntity category, String remoteUid);

  /// Deletes a custom category if it has no active transaction dependencies
  Future<void> deleteCategory(String categoryId, String remoteUid);
}

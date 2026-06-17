import 'package:spend_io_app/features/category/data/datasources/category_local_data_source.dart';
import 'package:spend_io_app/features/category/data/datasources/category_remote_data_source.dart';
import 'package:spend_io_app/features/category/data/models/category_model.dart';
import 'package:spend_io_app/features/category/domain/entities/category_entity.dart';
import 'package:spend_io_app/features/category/domain/repositories/category_repository.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryLocalDataSource localDataSource;
  final CategoryRemoteDataSource remoteDataSource;

  CategoryRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  // 🌟 ĐÃ BỔ SUNG: Lấy toàn bộ danh mục không phân biệt user phục vụ UseCase khởi tạo
  @override
  Future<List<CategoryEntity>> getAllCategories() async {
    return await localDataSource.getAllCategories();
  }

  // 🌟 ĐÃ BỔ SUNG: Chèn trực tiếp danh mục (Default/Custom) xuống SQLite local
  @override
  Future<void> insertCategory(CategoryEntity category) async {
    // Ép kiểu (Map) từ Entity sang Data Model trước khi đẩy xuống SQLite
    final model = CategoryModel(
      id: category.id,
      userId: category.userId,
      name: category.name,
      type: category.type,
      groupName: category.groupName,
      iconCodePoint: category.iconCodePoint,
      iconFontFamily: category.iconFontFamily ?? 'MaterialIcons',
      colorValue: category.colorValue,
      createdAt: category.createdAt,
      updatedAt: category.updatedAt,
    );

    await localDataSource.insertCategory(model);
  }

  @override
  Future<List<CategoryEntity>> getCategories(int localUserId) async {
    return await localDataSource.getCategories(localUserId);
  }

  @override
  Future<void> createCustomCategory(
      CategoryEntity category, String remoteUid) async {
    final model = CategoryModel(
      id: category.id,
      userId: category.userId,
      name: category.name,
      type: category.type,
      groupName: category.groupName,
      iconCodePoint: category.iconCodePoint,
      iconFontFamily: category.iconFontFamily ?? 'MaterialIcons',
      colorValue: category.colorValue,
      createdAt: category.createdAt,
      updatedAt: category.updatedAt,
    );

    // Write to local sqlite database instantly
    await localDataSource.insertCategory(model);

    // Cloud Guard: Only sync to firestore if online and it's a custom category (userId != 0)
    if (remoteUid.isNotEmpty && category.userId != 0) {
      await remoteDataSource.saveCustomCategory(remoteUid, model);
    }
  }

  @override
  Future<void> deleteCategory(String categoryId, String remoteUid) async {
    // If local validator fails (active transactions), execution stops here
    await localDataSource.deleteCategory(categoryId);

    // If local deletion succeeds, remove from the cloud storage safely
    if (remoteUid.isNotEmpty) {
      await remoteDataSource.removeCustomCategory(remoteUid, categoryId);
    }
  }
}

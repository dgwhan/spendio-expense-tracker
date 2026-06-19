import 'package:spend_io_app/features/budget/data/datasources/budget_local_data_source.dart';
import 'package:spend_io_app/features/budget/data/datasources/budget_remote_data_source.dart';
import 'package:spend_io_app/features/budget/data/models/budget_category_model.dart';
import 'package:spend_io_app/features/budget/data/models/budget_model.dart';
import 'package:spend_io_app/features/budget/domain/entities/category/budget_category_entity.dart';
import 'package:spend_io_app/features/budget/domain/entities/monthly/budget_entity.dart';
import 'package:spend_io_app/features/budget/domain/repositories/budget_repository.dart';

class BudgetRepositoryImpl implements BudgetRepository {
  final BudgetLocalDataSource localDataSource;
  final BudgetRemoteDataSource remoteDataSource;

  BudgetRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  // =========================================================
  // MONTHLY BUDGET (ĐỒNG BỘ SONG SONG)
  // =========================================================

  @override
  Future<BudgetEntity?> getCurrentBudget(int userId) async {
    final model = await localDataSource.getCurrentBudget(userId);
    // Trả về entity sạch cho tầng Domain sử dụng
    return model?.toEntity();
  }

  @override
  Future<void> createBudget(BudgetEntity budget) async {
    final model = BudgetModel.fromEntity(budget);

    // 1. Ghi và chặn log tại SQLite Local trước
    await localDataSource.createBudget(model);

    // 2. Kích hoạt đẩy đồng bộ thẳng lên Firebase Cloud liền tại trận
    await remoteDataSource.syncBudget(model);
  }

  @override
  Future<void> updateBudget(BudgetEntity budget) async {
    final model = BudgetModel.fromEntity(budget);
    await localDataSource.updateBudget(model);

    // Đồng bộ cập nhật bản ghi trên Cloud
    await remoteDataSource.syncBudget(model);
  }

  @override
  Future<void> deleteBudget(String budgetId) async {
    // ⚠️ Chú ý: Vì hàm xóa cần userId của Firebase, tụi mình cần bốc budget cũ từ local ra trước khi xóa
    final currentBudget =
        await localDataSource.getCurrentBudget(0); // Hoặc lấy qua map tạm

    await localDataSource.deleteBudget(budgetId);

    // Đồng bộ xóa trên Cloud (Fake tạm userId từ thực thể cũ hoặc nhận diện chuỗi)
    if (currentBudget != null) {
      await remoteDataSource.deleteBudget(budgetId, currentBudget.userId);
    }
  }

  // =========================================================
  // CATEGORY BUDGET (ĐỒNG BỘ SONG SONG)
  // =========================================================

  @override
  Future<List<BudgetCategoryEntity>> getBudgetCategories(int userId) async {
    final models = await localDataSource.getBudgetCategories(userId: userId);
    // Ép kiểu chuyển đổi từ Model danh mục mạng sang Entity miền lõi
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<void> createBudgetCategory(BudgetCategoryEntity category) async {
    final model = BudgetCategoryModel.fromEntity(category);
    await localDataSource.createBudgetCategory(model);

    // Kích hoạt đẩy danh mục ngân sách con lên Firebase
    await remoteDataSource.syncBudgetCategory(model);
  }

  @override
  Future<void> updateBudgetCategory(BudgetCategoryEntity category) async {
    final model = BudgetCategoryModel.fromEntity(category);
    await localDataSource.updateBudgetCategory(model);

    // Đồng bộ cập nhật danh mục con lên Firebase
    await remoteDataSource.syncBudgetCategory(model);
  }

  @override
  Future<void> deleteBudgetCategory(String categoryBudgetId) async {
    await localDataSource.deleteBudgetCategory(categoryBudgetId);
  }

  @override
  Future<bool> hasBudgetCategories(int userId) async {
    return localDataSource.hasBudgetCategories(userId);
  }

  // @override
  // Future<List<BudgetCategoryEntity>> getBudgetCategoriesByPeriod({
  //   required int userId,
  //   required DateTime date,
  // }) async {
  //   final models = await localDataSource.getBudgetCategoriesByPeriod(
  //     userId: userId,
  //     date: date,
  //   );
  //   return models.map((model) => model.toEntity()).toList();
  // }
}

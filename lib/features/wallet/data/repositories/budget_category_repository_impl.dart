import 'package:spend_io_app/features/wallet/data/datasources/budget/budget_local_data_source.dart';
import 'package:spend_io_app/features/wallet/data/models/budget_category_model.dart';
import 'package:spend_io_app/features/wallet/domain/entities/budget_category_entity.dart';
import 'package:spend_io_app/features/wallet/domain/repositories/budget_category_repository.dart';

class BudgetCategoryRepositoryImpl implements BudgetCategoryRepository {
  final BudgetLocalDataSource localDataSource;

  BudgetCategoryRepositoryImpl({
    required this.localDataSource,
  });

  @override
  Future<List<BudgetCategoryEntity>> getCategories(int localUserId) async {
    final models = await localDataSource.getCategories(localUserId);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<void> createCategory(int localUserId, BudgetCategoryEntity category) async {
    final model = BudgetCategoryModel.fromEntity(category);
    await localDataSource.insertCategory(localUserId, model);
  }

  @override
  Future<void> updateCategory(int localUserId, BudgetCategoryEntity category) async {
    final model = BudgetCategoryModel.fromEntity(category);
    await localDataSource.updateCategory(localUserId, model);
  }

  @override
  Future<bool> hasCategories(int userId) {
    return localDataSource.hasCategories(userId);
  }
}

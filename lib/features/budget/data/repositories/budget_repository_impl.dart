import 'package:spend_io_app/features/budget/data/datasources/budget_local_data_source.dart';
import 'package:spend_io_app/features/budget/data/datasources/budget_remote_data_source.dart';
import 'package:spend_io_app/features/budget/data/models/budget_category_model.dart';
import 'package:spend_io_app/features/budget/data/models/budget_model.dart';
import 'package:spend_io_app/features/budget/domain/entities/category/budget_category_entity.dart';
import 'package:spend_io_app/features/budget/domain/entities/budget_entity.dart';
import 'package:spend_io_app/features/budget/domain/repositories/budget_repository.dart';

class BudgetRepositoryImpl implements BudgetRepository {
  final BudgetLocalDataSource localDataSource;
  final BudgetRemoteDataSource remoteDataSource;

  BudgetRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  // =========================================================
  // MONTHLY BUDGET
  // =========================================================

  @override
  Future<BudgetEntity?> getCurrentBudget(int userId) async {
    final model = await localDataSource.getCurrentBudget(userId);
    return model?.toEntity();
  }

  @override
  Future<void> createBudget(BudgetEntity budget) async {
    final model = BudgetModel.fromEntity(budget);

    await localDataSource.createBudget(model);
    await remoteDataSource.syncBudget(model);
  }

  @override
  Future<void> updateBudget(BudgetEntity budget) async {
    final model = BudgetModel.fromEntity(budget);

    await localDataSource.updateBudget(model);
    await remoteDataSource.syncBudget(model);
  }

  // =========================================================
  // 🔥 FIXED DELETE (stateless, deterministic)
  // =========================================================

  @override
  Future<void> deleteBudget({
    required String budgetId,
    required int userId,
  }) async {
    // 1. delete local first (source of truth)
    await localDataSource.deleteBudget(budgetId);

    // 2. sync remote using explicit identity
    await remoteDataSource.deleteBudget(
      budgetId,
      userId,
    );
  }

  // =========================================================
  // CATEGORY BUDGET
  // =========================================================

  @override
  Future<List<BudgetCategoryEntity>> getBudgetCategories(int userId) async {
    final models = await localDataSource.getBudgetCategories(userId: userId);
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<void> createBudgetCategory(BudgetCategoryEntity category) async {
    final model = BudgetCategoryModel.fromEntity(category);

    await localDataSource.createBudgetCategory(model);
    await remoteDataSource.syncBudgetCategory(model);
  }

  @override
  Future<void> updateBudgetCategory(BudgetCategoryEntity category) async {
    final model = BudgetCategoryModel.fromEntity(category);

    await localDataSource.updateBudgetCategory(model);
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
}

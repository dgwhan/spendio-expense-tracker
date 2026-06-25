import 'package:flutter/foundation.dart';
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
    try {
      await remoteDataSource
          .syncBudget(model)
          .timeout(const Duration(seconds: 4));
    } catch (e) {
      debugPrint('[Budget Repo]: Cloud sync budget delayed ($e).');
    }
  }

  @override
  Future<void> updateBudget(BudgetEntity budget) async {
    final model = BudgetModel.fromEntity(budget);

    await localDataSource.updateBudget(model);
    try {
      await remoteDataSource
          .syncBudget(model)
          .timeout(const Duration(seconds: 4));
    } catch (e) {
      debugPrint('[Budget Repo]: Cloud sync budget delayed ($e).');
    }
  }

  // =========================================================
  // DELETE 
  // =========================================================

  @override
  Future<void> deleteBudget({
    required String budgetId,
    required int userId,
  }) async {
    //xóa trong local trước
    await localDataSource.deleteBudget(budgetId);

    //đồng bộ hóa remote
    try {
      await remoteDataSource
          .deleteBudget(budgetId, userId)
          .timeout(const Duration(seconds: 4));
    } catch (e) {
      debugPrint('[Budget Repo]: Cloud delete budget delayed ($e).');
    }
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
    try {
      await remoteDataSource
          .syncBudgetCategory(model)
          .timeout(const Duration(seconds: 4));
    } catch (e) {
      debugPrint('[Budget Category Repo]: Cloud sync category budget delayed ($e).');
    }
  }

  @override
  Future<void> updateBudgetCategory(BudgetCategoryEntity category) async {
    final model = BudgetCategoryModel.fromEntity(category);

    await localDataSource.updateBudgetCategory(model);
    try {
      await remoteDataSource
          .syncBudgetCategory(model)
          .timeout(const Duration(seconds: 4));
    } catch (e) {
      debugPrint('[Budget Category Repo]: Cloud sync category budget delayed ($e).');
    }
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

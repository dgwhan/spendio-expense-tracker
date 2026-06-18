import 'package:spend_io_app/features/budget/data/datasources/budget_local_data_source.dart';
import 'package:spend_io_app/features/budget/data/datasources/budget_remote_data_source.dart';

import 'package:spend_io_app/features/budget/data/models/budget_category_model.dart';
import 'package:spend_io_app/features/budget/data/models/budget_model.dart';

import 'package:spend_io_app/features/budget/domain/entities/budget_category_entity.dart';
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
  Future<BudgetEntity?> getCurrentBudget(
    int userId,
  ) async {
    return localDataSource.getCurrentBudget(userId);
  }

  @override
  Future<void> createBudget(
    BudgetEntity budget,
  ) async {
    await localDataSource.createBudget(
      BudgetModel.fromEntity(budget),
    );
  }

  @override
  Future<void> updateBudget(
    BudgetEntity budget,
  ) async {
    await localDataSource.updateBudget(
      BudgetModel.fromEntity(budget),
    );
  }

  @override
  Future<void> deleteBudget(
    String budgetId,
  ) async {
    await localDataSource.deleteBudget(
      budgetId,
    );
  }

  // =========================================================
  // CATEGORY BUDGET
  // =========================================================

  @override
  Future<List<BudgetCategoryEntity>> getBudgetCategories(
    int userId,
  ) async {
    return localDataSource.getBudgetCategories(
      userId: userId,
    );
  }

  @override
  Future<void> createBudgetCategory(
    BudgetCategoryEntity category,
  ) async {
    await localDataSource.createBudgetCategory(
      BudgetCategoryModel.fromEntity(category),
    );
  }

  @override
  Future<void> updateBudgetCategory(
    BudgetCategoryEntity category,
  ) async {
    await localDataSource.updateBudgetCategory(
      BudgetCategoryModel.fromEntity(category),
    );
  }

  @override
  Future<void> deleteBudgetCategory(
    String categoryBudgetId,
  ) async {
    await localDataSource.deleteBudgetCategory(
      categoryBudgetId,
    );
  }

  @override
  Future<bool> hasBudgetCategories(
    int userId,
  ) async {
    return localDataSource.hasBudgetCategories(
      userId,
    );
  }
}

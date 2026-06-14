import 'package:flutter_test/flutter_test.dart';
import 'package:spend_io_app/features/wallet/data/datasources/budget/budget_local_data_source.dart';
import 'package:spend_io_app/features/wallet/data/models/budget_category_model.dart';
import 'package:spend_io_app/features/wallet/data/repositories/budget_category_repository_impl.dart';
import 'package:spend_io_app/features/wallet/domain/entities/budget_category_entity.dart';

class FakeBudgetLocalDataSource implements BudgetLocalDataSource {
  final List<BudgetCategoryModel> categoriesDb = [];

  @override
  Future<List<BudgetCategoryModel>> getCategories(int userId) async => categoriesDb;

  @override
  Future<void> insertCategory(int userId, BudgetCategoryModel category) async {
    categoriesDb.removeWhere((c) => c.id == category.id);
    categoriesDb.add(category);
  }

  @override
  Future<void> updateCategory(int userId, BudgetCategoryModel category) async {
    categoriesDb.removeWhere((c) => c.id == category.id);
    categoriesDb.add(category);
  }

  @override
  Future<bool> hasCategories(int userId) async {
    return categoriesDb.isNotEmpty;
  }
}

void main() {
  late FakeBudgetLocalDataSource localDataSource;
  late BudgetCategoryRepositoryImpl repository;

  setUp(() {
    localDataSource = FakeBudgetLocalDataSource();
    repository = BudgetCategoryRepositoryImpl(
      localDataSource: localDataSource,
    );
  });

  group('BudgetCategoryRepositoryImpl CRUD Tests', () {
    test('createCategory() nên chèn SQLite', () async {
      final category = BudgetCategoryEntity(
        id: 'cat_1',
        name: 'Food',
        spent: 50.0,
        budget: 500.0,
      );

      await repository.createCategory(1, category);

      expect(localDataSource.categoriesDb.length, 1);
      expect(localDataSource.categoriesDb.first.id, 'cat_1');
    });

    test('updateCategory() nên cập nhật SQLite', () async {
      localDataSource.categoriesDb.add(BudgetCategoryModel(
        id: 'cat_1',
        name: 'Food',
        spent: 50.0,
        budget: 500.0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));

      final updatedCategory = BudgetCategoryEntity(
        id: 'cat_1',
        name: 'Food Modified',
        spent: 60.0,
        budget: 600.0,
      );

      await repository.updateCategory(1, updatedCategory);

      expect(localDataSource.categoriesDb.first.name, 'Food Modified');
      expect(localDataSource.categoriesDb.first.budget, 600.0);
    });
  });
}

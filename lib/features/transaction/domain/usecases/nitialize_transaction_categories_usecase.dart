import 'package:spend_io_app/features/category/domain/entities/category_entity.dart';
import 'package:spend_io_app/features/transaction/presentation/widgets/mock_categories_data.dart';

class InitializeTransactionCategoriesUseCase {
  final CategoryRepository repository;

  InitializeTransactionCategoriesUseCase(this.repository);

  Future<void> call(int localUserId) async {
    final existing = await repository.getCategories(localUserId);
    if (existing.isNotEmpty) return;

    for (final mock in mockCategoriesData) {
      await repository.createCategory(
        localUserId,
        CategoryEntity(
          id: mock.id,
          userId: localUserId,
          name: mock.name,
          iconCodePoint: mock.iconCodePoint,
          iconFontFamily: mock.iconFontFamily ?? 'MaterialIcons',
          colorValue: mock.colorValue,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
    }
  }
}

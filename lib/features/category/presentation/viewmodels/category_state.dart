import 'package:spend_io_app/features/category/domain/entities/category_entity.dart';

class CategoryState {
  final bool isLoading;
  final List<CategoryEntity> categories;
  final String? error;

  const CategoryState({
    this.isLoading = false,
    this.categories = const [],
    this.error,
  });

  CategoryState copyWith({
    bool? isLoading,
    List<CategoryEntity>? categories,
    String? error,
  }) {
    return CategoryState(
      isLoading: isLoading ?? this.isLoading,
      categories: categories ?? this.categories,
      error: error ?? this.error,
    );
  }
}

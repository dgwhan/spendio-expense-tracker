import 'package:spend_io_app/features/budget/domain/entities/budget_category_entity.dart';

class BudgetCategoryModel extends BudgetCategoryEntity {
  const BudgetCategoryModel({
    required super.id,
    required super.budgetId,
    required super.categoryId,
    required super.amount,
    required super.createdAt,
    required super.updatedAt,
  });

  factory BudgetCategoryModel.fromMap(Map<String, dynamic> map) {
    return BudgetCategoryModel(
      id: map['id'] as String,
      budgetId: map['budget_id'] as String,
      categoryId: map['category_id'] as String,
      amount: (map['amount'] as num).toDouble(),
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'budget_id': budgetId,
      'category_id': categoryId,
      'amount': amount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory BudgetCategoryModel.fromEntity(BudgetCategoryEntity entity) {
    return BudgetCategoryModel(
      id: entity.id,
      budgetId: entity.budgetId,
      categoryId: entity.categoryId,
      amount: entity.amount,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}

class BudgetCategoryEntity {
  final String id;

  final String budgetId;

  final String categoryId;

  final double amount;

  final DateTime createdAt;
  final DateTime updatedAt;

  const BudgetCategoryEntity({
    required this.id,
    required this.budgetId,
    required this.categoryId,
    required this.amount,
    required this.createdAt,
    required this.updatedAt,
  });

  BudgetCategoryEntity copyWith({
    String? id,
    String? budgetId,
    String? categoryId,
    double? amount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BudgetCategoryEntity(
      id: id ?? this.id,
      budgetId: budgetId ?? this.budgetId,
      categoryId: categoryId ?? this.categoryId,
      amount: amount ?? this.amount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

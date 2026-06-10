class BudgetCategoryEntity {
  final String id;
  final String name;
  final double spent;
  final double budget;

  const BudgetCategoryEntity({
    required this.id,
    required this.name,
    required this.spent,
    required this.budget,
  });

  double get progress {
    if (budget <= 0) return 0.0;
    final double calculatedProgress = spent / budget;
    return calculatedProgress.clamp(0.0, 1.0);
  }

  BudgetCategoryEntity copyWith({
    String? id,
    String? name,
    double? spent,
    double? budget,
  }) {
    return BudgetCategoryEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      spent: spent ?? this.spent,
      budget: budget ?? this.budget,
    );
  }
}

class BudgetCategoryModel {
  final String id;
  final String name;
  final double spent;
  final double budget;
  final String icon;

  const BudgetCategoryModel({
    required this.id,
    required this.name,
    required this.spent,
    required this.budget,
    required this.icon,
  });

  double get progress => spent / budget;
}

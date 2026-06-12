class SpendingItemModel {
  final String name;
  final double amount;
  final double percentage;

  const SpendingItemModel({
    required this.name,
    required this.amount,
    required this.percentage,
  });
}

class SpendingBreakdownModel {
  final String periodTitle;
  final double totalAmount;
  final List<SpendingItemModel> items;

  const SpendingBreakdownModel({
    required this.periodTitle,
    required this.totalAmount,
    required this.items,
  });
}

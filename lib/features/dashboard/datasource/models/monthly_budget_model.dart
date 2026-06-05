class MonthlyBudgetModel {
  final double totalBudget;
  final double totalSpent;
  final String monthName;

  const MonthlyBudgetModel({
    required this.totalBudget,
    required this.totalSpent,
    required this.monthName,
  });

  //tính số tiền còn lại
  double get remaining => totalBudget - totalSpent;

  // tính tỷ lệ phần trăm đã tiêu
  double get progress => totalBudget > 0 ? (totalSpent / totalBudget) : 0.0;
}

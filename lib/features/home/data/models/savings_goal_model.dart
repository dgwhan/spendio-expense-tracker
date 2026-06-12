class SavingsGoalModel {
  final String id;
  final String title;
  final String category;
  final double currentAmount;
  final double targetAmount;
  final String status;
  final String iconType;

  const SavingsGoalModel({
    required this.id,
    required this.title,
    required this.category,
    required this.currentAmount,
    required this.targetAmount,
    required this.status,
    required this.iconType,
  });

  //tính tỷ lệ tiến trình
  double get progress =>
      targetAmount > 0 ? (currentAmount / targetAmount) : 0.0;
}

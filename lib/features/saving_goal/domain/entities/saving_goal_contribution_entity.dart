class SavingGoalContributionEntity {
  final String id;
  final String goalId;
  final int userId;

  final double amount;

  final DateTime createdAt;
  final String currencyCode;

  const SavingGoalContributionEntity({
    required this.id,
    required this.goalId,
    required this.userId,
    required this.amount,
    required this.createdAt,
    this.currencyCode = 'USD',
  });
}

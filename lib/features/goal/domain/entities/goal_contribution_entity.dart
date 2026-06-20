class GoalContributionEntity {
  final String id;
  final String goalId;
  final int userId;

  final double amount;

  final DateTime createdAt;

  const GoalContributionEntity({
    required this.id,
    required this.goalId,
    required this.userId,
    required this.amount,
    required this.createdAt,
  });
}

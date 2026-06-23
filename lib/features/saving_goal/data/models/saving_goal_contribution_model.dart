import '../../domain/entities/saving_goal_contribution_entity.dart';

class GoalContributionModel extends SavingGoalContributionEntity {
  const GoalContributionModel({
    required super.id,
    required super.goalId,
    required super.userId,
    required super.amount,
    required super.createdAt,
    required super.currencyCode,
  });

  factory GoalContributionModel.fromMap(Map<String, dynamic> map) {
    return GoalContributionModel(
      id: map['id'] as String,
      goalId: map['goal_id'] as String,
      userId: map['user_id'] as int,
      amount: (map['amount'] as num).toDouble(),
      createdAt: DateTime.parse(map['created_at']),
      currencyCode: (map['currency_code'] as String?) ?? 'USD',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'goal_id': goalId,
      'user_id': userId,
      'amount': amount,
      'created_at': createdAt.toIso8601String(),
      'currency_code': currencyCode,
    };
  }

  factory GoalContributionModel.fromEntity(
    SavingGoalContributionEntity entity,
  ) {
    return GoalContributionModel(
      id: entity.id,
      goalId: entity.goalId,
      userId: entity.userId,
      amount: entity.amount,
      createdAt: entity.createdAt,
      currencyCode: entity.currencyCode,
    );
  }

  SavingGoalContributionEntity toEntity() => this;
}

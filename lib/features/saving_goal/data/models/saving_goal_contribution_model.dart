import '../../domain/entities/saving_goal_contribution_entity.dart';

class GoalContributionModel extends SavingGoalContributionEntity {
  const GoalContributionModel({
    required super.id,
    required super.goalId,
    required super.userId,
    required super.amount,
    required super.createdAt,
  });

  factory GoalContributionModel.fromMap(Map<String, dynamic> map) {
    return GoalContributionModel(
      id: map['id'] as String,
      goalId: map['goal_id'] as String,
      userId: map['user_id'] as int,
      amount: (map['amount'] as num).toDouble(),
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'goal_id': goalId,
      'user_id': userId,
      'amount': amount,
      'created_at': createdAt.toIso8601String(),
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
    );
  }

  SavingGoalContributionEntity toEntity() => this;
}

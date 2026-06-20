import '../../domain/entities/goal_entity.dart';

class GoalModel extends GoalEntity {
  const GoalModel({
    required super.id,
    required super.userId,
    required super.title,
    required super.targetAmount,
    required super.initialAmount,
    required super.cachedCurrentAmount,
    required super.cachedProgress,
    required super.icon,
    required super.color,
    required super.status,
    required super.createdAt,
    required super.updatedAt,
  });

  factory GoalModel.fromMap(Map<String, dynamic> map) {
    return GoalModel(
      id: map['id'] as String,
      userId: map['user_id'] as int,
      title: map['title'] as String,
      targetAmount: (map['target_amount'] as num).toDouble(),
      initialAmount: (map['initial_amount'] as num).toDouble(),
      cachedCurrentAmount: (map['cached_current_amount'] as num).toDouble(),
      cachedProgress: (map['cached_progress'] as num).toDouble(),
      icon: map['icon'] as String?,
      color: map['color'] as int?,
      status: map['status'] as String,
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'target_amount': targetAmount,
      'initial_amount': initialAmount,
      'cached_current_amount': cachedCurrentAmount,
      'cached_progress': cachedProgress,
      'icon': icon,
      'color': color,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory GoalModel.fromEntity(GoalEntity entity) {
    return GoalModel(
      id: entity.id,
      userId: entity.userId,
      title: entity.title,
      targetAmount: entity.targetAmount,
      initialAmount: entity.initialAmount,
      cachedCurrentAmount: entity.cachedCurrentAmount,
      cachedProgress: entity.cachedProgress,
      icon: entity.icon,
      color: entity.color,
      status: entity.status,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  GoalEntity toEntity() => this;
}

class GoalEntity {
  final String id;
  final int userId;

  final String title;

  final double targetAmount;
  final double initialAmount;

  final double cachedCurrentAmount;
  final double cachedProgress;

  final String? icon;
  final int? color;

  final String status;

  final DateTime createdAt;
  final DateTime updatedAt;

  const GoalEntity({
    required this.id,
    required this.userId,
    required this.title,
    required this.targetAmount,
    required this.initialAmount,
    required this.cachedCurrentAmount,
    required this.cachedProgress,
    required this.icon,
    required this.color,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  GoalEntity copyWith({
    String? id,
    int? userId,
    String? title,
    double? targetAmount,
    double? initialAmount,
    double? cachedCurrentAmount,
    double? cachedProgress,
    String? icon,
    int? color,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return GoalEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      targetAmount: targetAmount ?? this.targetAmount,
      initialAmount: initialAmount ?? this.initialAmount,
      cachedCurrentAmount: cachedCurrentAmount ?? this.cachedCurrentAmount,
      cachedProgress: cachedProgress ?? this.cachedProgress,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

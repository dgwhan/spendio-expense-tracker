class SavingGoalEntity {
  final String id;
  final int userId;

  final String title;

  final double targetAmount;
  final double initialAmount;

  final double cachedCurrentAmount;
  final double cachedProgress;

  final int iconCodePoint;
  final String iconFontFamily;

  final int colorValue;

  final String status;

  final DateTime createdAt;
  final DateTime updatedAt;
  final String currencyCode;

  const SavingGoalEntity({
    required this.id,
    required this.userId,
    required this.title,
    required this.targetAmount,
    required this.initialAmount,
    required this.cachedCurrentAmount,
    required this.cachedProgress,
    required this.iconCodePoint,
    required this.iconFontFamily,
    required this.colorValue,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.currencyCode = 'USD',
  });

  SavingGoalEntity copyWith({
    String? id,
    int? userId,
    String? title,
    double? targetAmount,
    double? initialAmount,
    double? cachedCurrentAmount,
    double? cachedProgress,
    int? iconCodePoint,
    String? iconFontFamily,
    int? colorValue,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? currencyCode,
  }) {
    return SavingGoalEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      targetAmount: targetAmount ?? this.targetAmount,
      initialAmount: initialAmount ?? this.initialAmount,
      cachedCurrentAmount: cachedCurrentAmount ?? this.cachedCurrentAmount,
      cachedProgress: cachedProgress ?? this.cachedProgress,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
      iconFontFamily: iconFontFamily ?? this.iconFontFamily,
      colorValue: colorValue ?? this.colorValue,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      currencyCode: currencyCode ?? this.currencyCode,
    );
  }
}

import '../../domain/entities/saving_goal_entity.dart';

class SavingGoalModel extends SavingGoalEntity {
  const SavingGoalModel({
    required super.id,
    required super.userId,
    required super.title,
    required super.targetAmount,
    required super.initialAmount,
    required super.cachedCurrentAmount,
    required super.cachedProgress,
    required super.iconCodePoint,
    required super.iconFontFamily,
    required super.colorValue,
    required super.status,
    required super.createdAt,
    required super.updatedAt,
    required super.currencyCode,
  });

  factory SavingGoalModel.fromMap(Map<String, dynamic> map) {
    return SavingGoalModel(
      id: map['id'] as String,
      userId: map['user_id'] as int,
      title: map['title'] as String,
      targetAmount: (map['target_amount'] as num).toDouble(),
      initialAmount: (map['initial_amount'] as num).toDouble(),
      cachedCurrentAmount: (map['cached_current_amount'] as num).toDouble(),
      cachedProgress: (map['cached_progress'] as num).toDouble(),
      iconCodePoint: map['icon_code_point'] as int? ?? 0,
      iconFontFamily: map['icon_font_family'] as String? ?? 'MaterialIcons',
      colorValue: map['color_value'] as int? ?? 0,
      status: map['status'] as String,
      createdAt: DateTime.parse(
        map['created_at'] as String,
      ),
      updatedAt: DateTime.parse(
        map['updated_at'] as String,
      ),
      currencyCode: (map['currency_code'] as String?) ?? 'USD',
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
      'icon_code_point': iconCodePoint,
      'icon_font_family': iconFontFamily,
      'color_value': colorValue,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'currency_code': currencyCode,
    };
  }

  factory SavingGoalModel.fromEntity(
    SavingGoalEntity entity,
  ) {
    return SavingGoalModel(
      id: entity.id,
      userId: entity.userId,
      title: entity.title,
      targetAmount: entity.targetAmount,
      initialAmount: entity.initialAmount,
      cachedCurrentAmount: entity.cachedCurrentAmount,
      cachedProgress: entity.cachedProgress,
      iconCodePoint: entity.iconCodePoint,
      iconFontFamily: entity.iconFontFamily,
      colorValue: entity.colorValue,
      status: entity.status,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      currencyCode: entity.currencyCode,
    );
  }

  SavingGoalEntity toEntity() => this;
}

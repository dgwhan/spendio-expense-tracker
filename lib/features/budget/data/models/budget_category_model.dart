import 'package:spend_io_app/features/budget/domain/entities/category/budget_category_entity.dart';
import 'package:spend_io_app/features/budget/domain/entities/budget_period.dart';

class BudgetCategoryModel extends BudgetCategoryEntity {
  const BudgetCategoryModel({
    required super.id,
    required super.userId,
    required super.categoryId,
    required super.name,
    required super.amount,
    required super.currencyCode,
    required super.periodType,
    required super.startDate,
    required super.endDate,
    required super.createdAt,
    required super.updatedAt,
  });

  BudgetCategoryEntity toEntity() {
    return BudgetCategoryEntity(
      id: id,
      userId: userId,
      categoryId: categoryId,
      name: name,
      amount: amount,
      currencyCode: currencyCode,
      periodType: periodType,
      startDate: startDate,
      endDate: endDate,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory BudgetCategoryModel.fromMap(Map<String, dynamic> map) {
    return BudgetCategoryModel(
      id: map['id'] as String,
      userId: map['user_id'] as int,
      categoryId: map['category_id'] as String,
      name: map['name'] as String? ?? '',
      amount: (map['amount'] as num).toDouble(),
      currencyCode: (map['currency_code'] as String?) ?? 'USD',
      periodType: BudgetPeriod.values.firstWhere(
        (e) => e.name == map['period_type'],
        orElse: () => BudgetPeriod.monthly,
      ),
      startDate: DateTime.parse(map['start_date'] as String),
      endDate: DateTime.parse(map['end_date'] as String),
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'category_id': categoryId,
      'name': name,
      'amount': amount,
      'currency_code': currencyCode,
      'period_type': periodType.name,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory BudgetCategoryModel.fromEntity(
    BudgetCategoryEntity entity,
  ) {
    return BudgetCategoryModel(
      id: entity.id,
      userId: entity.userId,
      categoryId: entity.categoryId,
      name: entity.name,
      amount: entity.amount,
      currencyCode: entity.currencyCode,
      periodType: entity.periodType,
      startDate: entity.startDate,
      endDate: entity.endDate,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}

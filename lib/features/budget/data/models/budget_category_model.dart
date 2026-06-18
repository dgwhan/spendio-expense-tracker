import 'package:spend_io_app/features/budget/domain/entities/budget_category_entity.dart';
import 'package:spend_io_app/features/budget/domain/entities/budget_period.dart';

class BudgetCategoryModel extends BudgetCategoryEntity {
  const BudgetCategoryModel({
    required super.id,
    required super.userId,
    required super.categoryId,
    required super.amount,
    required super.periodType,
    required super.startDate,
    required super.endDate,
    required super.createdAt,
    required super.updatedAt,
  });

  factory BudgetCategoryModel.fromMap(Map<String, dynamic> map) {
    return BudgetCategoryModel(
      id: map['id'] as String,
      userId: map['user_id'] as int,
      categoryId: map['category_id'] as String,
      amount: (map['amount'] as num).toDouble(),
      periodType: BudgetPeriod.values.firstWhere(
        (e) => e.name == map['period_type'],
      ),
      startDate: DateTime.parse(map['start_date']),
      endDate: DateTime.parse(map['end_date']),
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'category_id': categoryId,
      'amount': amount,
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
      amount: entity.amount,
      periodType: entity.periodType,
      startDate: entity.startDate,
      endDate: entity.endDate,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}

import 'package:spend_io_app/features/budget/domain/entities/monthly/budget_entity.dart';
import 'package:spend_io_app/features/budget/domain/entities/budget_period.dart';

class BudgetModel extends BudgetEntity {
  const BudgetModel({
    required super.id,
    required super.userId,
    required super.name,
    required super.amount,
    required super.periodType,
    required super.startDate,
    required super.endDate,
    required super.createdAt,
    required super.updatedAt,
  });

  BudgetEntity toEntity() {
    return BudgetEntity(
      id: id,
      userId: userId,
      name: name,
      amount: amount,
      periodType: periodType,
      startDate: startDate,
      endDate: endDate,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory BudgetModel.fromMap(Map<String, dynamic> map) {
    return BudgetModel(
      id: map['id'] as String,
      userId: map['user_id'] as int,
      name: map['name'] as String,
      amount: (map['amount'] as num).toDouble(),
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
      'name': name,
      'amount': amount,
      'period_type': periodType.name,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory BudgetModel.fromEntity(BudgetEntity entity) {
    return BudgetModel(
      id: entity.id,
      userId: entity.userId,
      name: entity.name,
      amount: entity.amount,
      periodType: entity.periodType,
      startDate: entity.startDate,
      endDate: entity.endDate,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}

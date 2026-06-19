import 'package:spend_io_app/features/budget/domain/entities/budget_period.dart';

class BudgetEntity {
  final String id;
  final int userId;

  final String name;

  final double amount;

  final BudgetPeriod periodType;

  final DateTime startDate;
  final DateTime endDate;

  final DateTime createdAt;
  final DateTime updatedAt;

  const BudgetEntity({
    required this.id,
    required this.userId,
    required this.name,
    required this.amount,
    required this.periodType,
    required this.startDate,
    required this.endDate,
    required this.createdAt,
    required this.updatedAt,
  });

  BudgetEntity copyWith({
    String? id,
    int? userId,
    String? name,
    double? amount,
    BudgetPeriod? periodType,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BudgetEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      periodType: periodType ?? this.periodType,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

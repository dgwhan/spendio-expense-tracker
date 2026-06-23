import 'package:spend_io_app/features/budget/domain/entities/budget_period.dart';

class BudgetCategoryEntity {
  final String id;
  final int userId;
  final String categoryId;
  final String name;
  final double amount;

  final String currencyCode;

  final BudgetPeriod periodType;

  final DateTime startDate;
  final DateTime endDate;

  final DateTime createdAt;
  final DateTime updatedAt;

  const BudgetCategoryEntity({
    required this.id,
    required this.userId,
    required this.categoryId,
    required this.name,
    required this.amount,
    required this.currencyCode,
    required this.periodType,
    required this.startDate,
    required this.endDate,
    required this.createdAt,
    required this.updatedAt,
  });

  BudgetCategoryEntity copyWith({
    String? id,
    int? userId,
    String? categoryId,
    String? name,
    double? amount,
    String? currencyCode,
    BudgetPeriod? periodType,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BudgetCategoryEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      categoryId: categoryId ?? this.categoryId,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      currencyCode: currencyCode ?? this.currencyCode,
      periodType: periodType ?? this.periodType,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

import 'package:spend_io_app/features/transaction/domain/entities/transaction_type.dart';

class TransactionEntity {
  final String id;
  final int userId;
  final String accountId;
  final String categoryId;
  final double amount;
  final TransactionType type;
  final String? note;
  final DateTime transactionDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TransactionEntity({
    required this.id,
    required this.userId,
    required this.accountId,
    required this.categoryId,
    required this.amount,
    required this.type,
    this.note,
    required this.transactionDate,
    required this.createdAt,
    required this.updatedAt,
  });

  TransactionEntity copyWith({
    String? id,
    int? userId,
    String? accountId,
    String? categoryId,
    double? amount,
    TransactionType? type,
    String? note,
    DateTime? transactionDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TransactionEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      accountId: accountId ?? this.accountId,
      categoryId: categoryId ?? this.categoryId,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      note: note ?? this.note,
      transactionDate: transactionDate ?? this.transactionDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

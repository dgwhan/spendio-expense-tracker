
import 'package:spend_io_app/features/transaction/domain/entities/transaction_entity.dart';
import 'package:spend_io_app/features/transaction/domain/entities/transaction_type.dart';

class TransactionModel {
  final String id;
  final int userId;
  final String accountId;
  final String categoryId;
  final double amount;
  final String type;
  final String? note;
  final String transactionDate;
  final String createdAt;
  final String updatedAt;
  final String currencyCode;

  TransactionModel({
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
    this.currencyCode = 'USD',
  });

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'] as String,
      userId: map['user_id'] as int,
      accountId: map['account_id'] as String,
      categoryId: map['category_id'] as String,
      amount: (map['amount'] as num).toDouble(),
      type: map['type'] as String,
      note: map['note'] as String?,
      transactionDate: map['transaction_date'] as String,
      createdAt: map['created_at'] as String,
      updatedAt: map['updated_at'] as String,
      currencyCode: (map['currency_code'] as String?) ?? 'USD',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'account_id': accountId,
      'category_id': categoryId,
      'amount': amount,
      'type': type,
      'note': note,
      'transaction_date': transactionDate,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'currency_code': currencyCode,
    };
  }

  TransactionEntity toEntity() {
    return TransactionEntity(
      id: id,
      userId: userId,
      accountId: accountId,
      categoryId: categoryId,
      amount: amount,
      type: type == 'income' ? TransactionType.income : TransactionType.expense,
      note: note,
      transactionDate: DateTime.parse(transactionDate),
      createdAt: DateTime.parse(createdAt),
      updatedAt: DateTime.parse(updatedAt),
      currencyCode: currencyCode,
    );
  }

  factory TransactionModel.fromEntity(TransactionEntity entity) {
    return TransactionModel(
      id: entity.id,
      userId: entity.userId,
      accountId: entity.accountId,
      categoryId: entity.categoryId,
      amount: entity.amount,
      type: entity.type.name,
      note: entity.note,
      transactionDate: entity.transactionDate.toIso8601String(),
      createdAt: entity.createdAt.toIso8601String(),
      updatedAt: entity.updatedAt.toIso8601String(),
      currencyCode: entity.currencyCode,
    );
  }
}

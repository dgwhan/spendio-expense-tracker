import 'package:spend_io_app/features/transaction/domain/entities/transaction_entity.dart';

class TransactionRules {
  static void validate(TransactionEntity tx) {
    if (tx.amount <= 0) {
      throw Exception('Amount must be greater than 0');
    }

    if (tx.accountId.isEmpty) {
      throw Exception('Account is required');
    }

    if (tx.categoryId.isEmpty) {
      throw Exception('Category is required');
    }
  }
}

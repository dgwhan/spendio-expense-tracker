import 'package:spend_io_app/features/transaction/domain/entities/transaction_entity.dart';

abstract class TransactionRepository {
  // =========================================================
  // CRUD
  // =========================================================

  Future<List<TransactionEntity>> getAllTransactions(int userId);

  Future<List<TransactionEntity>> getTransactionsByAccount(
    String accountId,
  );

  Future<void> createTransaction(
    TransactionEntity transaction,
  );

  Future<void> updateTransaction({
    required TransactionEntity newTransaction,
    required TransactionEntity oldTransaction,
  });

  Future<void> deleteTransaction(
    TransactionEntity transaction,
  );

  // =========================================================
  // ANALYTICS
  // =========================================================

  Future<Map<String, double>> getSpentGroupByCategory({
    required int userId,
    required DateTime startDate,
    required DateTime endDate,
    String? targetCurrencyCode,
  });

  Future<double> getTotalSpentInPeriod({
    required int userId,
    required DateTime startDate,
    required DateTime endDate,
    String? targetCurrencyCode,
  });

  Future<double> getTotalSpentByCategory({
    required int userId,
    required String categoryId,
    required DateTime startDate,
    required DateTime endDate,
    String? targetCurrencyCode,
  });
}

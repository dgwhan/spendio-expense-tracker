import 'package:spend_io_app/features/transaction/domain/entities/transaction_entity.dart';

abstract class TransactionRepository {
  Future<List<TransactionEntity>> getAllTransactions();

  Future<List<TransactionEntity>> getTransactionsByAccount(String accountId);
  Future<void> createTransaction(TransactionEntity transaction);

  Future<void> updateTransaction({
    required TransactionEntity newTransaction,
    required TransactionEntity oldTransaction,
  });

  Future<void> deleteTransaction(TransactionEntity transaction);
}

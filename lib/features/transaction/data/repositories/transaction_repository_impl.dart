import 'package:flutter/foundation.dart';
import 'package:spend_io_app/features/transaction/data/datasource/transaction_local_data_source.dart';
import 'package:spend_io_app/features/transaction/data/datasource/transaction_remote_data_source.dart';
import 'package:spend_io_app/features/transaction/data/models/transaction_model.dart';
import 'package:spend_io_app/features/transaction/domain/entities/transaction_entity.dart';
import 'package:spend_io_app/features/transaction/domain/repositories/transaction_repository.dart';
import 'package:spend_io_app/features/transaction/domain/usecases/update_wallet_balance.dart';
import 'package:spend_io_app/features/transaction/presentation/widgets/transaction_rules.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionLocalDataSource localDataSource;
  final TransactionRemoteDataSource remoteDataSource;
  final UpdateWalletBalance updateWalletBalance;
  final String remoteUid;

  TransactionRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.updateWalletBalance,
    required this.remoteUid,
  });

  @override
  Future<List<TransactionEntity>> getTransactionsByAccount(
      String accountId) async {
    final models = await localDataSource.getByAccountId(accountId);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<void> createTransaction(TransactionEntity transaction) async {
    TransactionRules.validate(transaction);

    final model = TransactionModel.fromEntity(transaction);

    await localDataSource.insert(model);
    debugPrint('[TransactionRepo] Inserted locally: ${model.id}');

    if (remoteUid.isNotEmpty) {
      try {
        await remoteDataSource.saveTransaction(remoteUid, model);
      } catch (e) {
        debugPrint('[TransactionRepo] Remote save failed, offline mode: $e');
      }
    }

    await updateWalletBalance.onCreate(transaction);
  }

  @override
  Future<void> updateTransaction({
    required TransactionEntity newTransaction,
    required TransactionEntity oldTransaction,
  }) async {
    TransactionRules.validate(newTransaction);

    final model = TransactionModel.fromEntity(newTransaction);

    await localDataSource.update(model);
    debugPrint('[TransactionRepo] Updated locally: ${model.id}');

    if (remoteUid.isNotEmpty) {
      try {
        await remoteDataSource.saveTransaction(remoteUid, model);
      } catch (e) {
        debugPrint('[TransactionRepo] Remote update failed, offline mode: $e');
      }
    }

    await updateWalletBalance.onUpdate(newTransaction, oldTransaction);
  }

  @override
  Future<void> deleteTransaction(TransactionEntity transaction) async {
    await localDataSource.delete(transaction.id);
    debugPrint('[TransactionRepo] Deleted locally: ${transaction.id}');

    if (remoteUid.isNotEmpty) {
      try {
        await remoteDataSource.removeTransaction(remoteUid, transaction.id);
      } catch (e) {
        debugPrint('[TransactionRepo] Remote delete failed, offline mode: $e');
      }
    }

    await updateWalletBalance.onDelete(transaction);
  }
}

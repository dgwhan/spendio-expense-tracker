import 'package:flutter/foundation.dart';
import 'package:spend_io_app/features/account/domain/entities/account_entity.dart';
import 'package:spend_io_app/features/account/domain/repositories/account_repository.dart';
import 'package:spend_io_app/features/transaction/data/datasource/transaction_local_data_source.dart';
import 'package:spend_io_app/features/transaction/data/datasource/transaction_remote_data_source.dart';
import 'package:spend_io_app/features/transaction/data/models/transaction_model.dart';
import 'package:spend_io_app/features/transaction/domain/entities/transaction_entity.dart';
import 'package:spend_io_app/features/transaction/domain/entities/transaction_type.dart';
import 'package:spend_io_app/features/transaction/domain/repositories/transaction_repository.dart';
import 'package:spend_io_app/features/transaction/presentation/widgets/transaction_rules.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionLocalDataSource localDataSource;
  final TransactionRemoteDataSource remoteDataSource;
  final AccountRepository accountRepository;
  final String remoteUid;

  TransactionRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.accountRepository,
    required this.remoteUid,
  });

  // 🌟 @override HÀM MỚI: Lấy tất cả giao dịch không phân biệt tài khoản
  @override
  Future<List<TransactionEntity>> getAllTransactions() async {
    // Gọi hàm bốc sạch dữ liệu từ SQLite/Local của bà lên
    final models = await localDataSource.getAll();

    return models
        .map(
          (model) => model.toEntity(),
        )
        .toList();
  }

  @override
  Future<List<TransactionEntity>> getTransactionsByAccount(
    String accountId,
  ) async {
    final models = await localDataSource.getByAccountId(accountId);

    return models
        .map(
          (model) => model.toEntity(),
        )
        .toList();
  }

  @override
  Future<void> createTransaction(
    TransactionEntity transaction,
  ) async {
    TransactionRules.validate(transaction);

    final model = TransactionModel.fromEntity(
      transaction,
    );

    await localDataSource.insert(
      model,
    );

    debugPrint(
      '[TransactionRepo] Inserted locally: ${model.id}',
    );

    if (remoteUid.isNotEmpty) {
      try {
        await remoteDataSource.saveTransaction(
          remoteUid,
          model,
        );
      } catch (e) {
        debugPrint(
          '[TransactionRepo] Remote save failed: $e',
        );
      }
    }

    await _applyTransactionBalance(
      transaction,
    );
  }

  @override
  Future<void> updateTransaction({
    required TransactionEntity newTransaction,
    required TransactionEntity oldTransaction,
  }) async {
    TransactionRules.validate(
      newTransaction,
    );

    final model = TransactionModel.fromEntity(
      newTransaction,
    );

    await localDataSource.update(
      model,
    );

    debugPrint(
      '[TransactionRepo] Updated locally: ${model.id}',
    );

    if (remoteUid.isNotEmpty) {
      try {
        await remoteDataSource.saveTransaction(
          remoteUid,
          model,
        );
      } catch (e) {
        debugPrint(
          '[TransactionRepo] Remote update failed: $e',
        );
      }
    }

    await _rollbackTransactionBalance(
      oldTransaction,
    );

    await _applyTransactionBalance(
      newTransaction,
    );
  }

  @override
  Future<void> deleteTransaction(
    TransactionEntity transaction,
  ) async {
    await localDataSource.delete(
      transaction.id,
    );

    debugPrint(
      '[TransactionRepo] Deleted locally: ${transaction.id}',
    );

    if (remoteUid.isNotEmpty) {
      try {
        await remoteDataSource.removeTransaction(
          remoteUid,
          transaction.id,
        );
      } catch (e) {
        debugPrint(
          '[TransactionRepo] Remote delete failed: $e',
        );
      }
    }

    await _rollbackTransactionBalance(
      transaction,
    );
  }

  // ==========================
  // balance engine
  // ==========================

  Future<AccountEntity> _findAccount(
    int userId,
    String accountId,
  ) async {
    final accounts = await accountRepository.getAccounts(
      userId,
      remoteUid,
    );

    try {
      return accounts.firstWhere(
        (account) => account.id == accountId,
      );
    } catch (_) {
      throw StateError(
        '[TransactionRepo] Account not found: $accountId',
      );
    }
  }

  Future<void> _applyTransactionBalance(
    TransactionEntity transaction,
  ) async {
    final account = await _findAccount(
      transaction.userId,
      transaction.accountId,
    );

    double newBalance = account.balance;

    switch (transaction.type) {
      case TransactionType.income:
        newBalance += transaction.amount;
        break;

      case TransactionType.expense:
        newBalance -= transaction.amount;
        break;
    }

    final updatedAccount = account.copyWith(
      balance: newBalance,
      updatedAt: DateTime.now(),
    );

    await accountRepository.updateAccount(
      transaction.userId,
      remoteUid,
      updatedAccount,
    );

    debugPrint(
      '[TransactionRepo] Balance updated: ${account.id} -> $newBalance',
    );
  }

  Future<void> _rollbackTransactionBalance(
    TransactionEntity transaction,
  ) async {
    final account = await _findAccount(
      transaction.userId,
      transaction.accountId,
    );

    double newBalance = account.balance;

    switch (transaction.type) {
      case TransactionType.income:
        newBalance -= transaction.amount;
        break;

      case TransactionType.expense:
        newBalance += transaction.amount;
        break;
    }

    final updatedAccount = account.copyWith(
      balance: newBalance,
      updatedAt: DateTime.now(),
    );

    await accountRepository.updateAccount(
      transaction.userId,
      remoteUid,
      updatedAccount,
    );

    debugPrint(
      '[TransactionRepo] Balance rollback: ${account.id} -> $newBalance',
    );
  }
}

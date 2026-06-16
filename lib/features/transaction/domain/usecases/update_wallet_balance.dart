import 'package:spend_io_app/features/wallet/domain/repositories/wallet_repository.dart';
import '../entities/transaction_entity.dart';
import '../services/wallet_balance_service.dart';

// UpdateWalletBalance coordinates balance recalculation and persistence.
// It calls updateAccountBalance (not updateAccount) so the operation bypasses
// the sync pipeline's Sync Guard entirely.
class UpdateWalletBalance {
  final WalletRepository walletRepository;

  // remoteUid is injected so the use case can trigger the Firestore patch
  // in the same atomic call without requiring a separate sync pass.
  final String remoteUid;
  final int localUserId;

  UpdateWalletBalance(
    this.walletRepository, {
    required this.remoteUid,
    required this.localUserId,
  });

  Future<void> onCreate(TransactionEntity tx) async {
    final account = await walletRepository.getAccount(tx.accountId);

    final newBalance = WalletBalanceService.recalculate(
      currentBalance: account.balance,
      tx: tx,
      operation: OperationType.create,
    );

    await walletRepository.updateAccountBalance(
      localUserId: localUserId,
      remoteUid: remoteUid,
      accountId: tx.accountId,
      newBalance: newBalance,
    );
  }

  Future<void> onDelete(TransactionEntity tx) async {
    final account = await walletRepository.getAccount(tx.accountId);

    final newBalance = WalletBalanceService.recalculate(
      currentBalance: account.balance,
      tx: tx,
      operation: OperationType.delete,
    );

    await walletRepository.updateAccountBalance(
      localUserId: localUserId,
      remoteUid: remoteUid,
      accountId: tx.accountId,
      newBalance: newBalance,
    );
  }

  Future<void> onUpdate(
      TransactionEntity newTx, TransactionEntity oldTx) async {
    final account = await walletRepository.getAccount(newTx.accountId);

    final newBalance = WalletBalanceService.recalculate(
      currentBalance: account.balance,
      tx: newTx,
      oldTx: oldTx,
      operation: OperationType.update,
    );

    await walletRepository.updateAccountBalance(
      localUserId: localUserId,
      remoteUid: remoteUid,
      accountId: newTx.accountId,
      newBalance: newBalance,
    );
  }
}

// import 'package:spend_io_app/features/account/domain/repositories/account_repository.dart';
// import 'package:spend_io_app/features/transaction/domain/entities/transaction_entity.dart';
// import 'package:spend_io_app/features/transaction/domain/services/wallet_balance_service.dart';

// class UpdateWalletBalance {
//   final AccountRepository accountRepository;

//   final String remoteUid;
//   final int localUserId;

//   UpdateWalletBalance(
//     this.accountRepository, {
//     required this.remoteUid,
//     required this.localUserId,
//   });

//   Future<void> onCreate(TransactionEntity tx) async {
//     final account = await accountRepository.getAccountById(tx.accountId);

//     final newBalance = WalletBalanceService.recalculate(
//       currentBalance: account.balance,
//       tx: tx,
//       operation: OperationType.create,
//     );

//     await accountRepository.updateAccountBalance(
//       localUserId: localUserId,
//       remoteUid: remoteUid,
//       accountId: tx.accountId,
//       newBalance: newBalance,
//     );
//   }

//   Future<void> onDelete(TransactionEntity tx) async {
//     final account = await accountRepository.getAccountById(tx.accountId);

//     final newBalance = WalletBalanceService.recalculate(
//       currentBalance: account.balance,
//       tx: tx,
//       operation: OperationType.delete,
//     );

//     await accountRepository.updateAccountBalance(
//       localUserId: localUserId,
//       remoteUid: remoteUid,
//       accountId: tx.accountId,
//       newBalance: newBalance,
//     );
//   }

//   Future<void> onUpdate(
//     TransactionEntity newTx,
//     TransactionEntity oldTx,
//   ) async {
//     final account = await accountRepository.getAccountById(newTx.accountId);

//     final newBalance = WalletBalanceService.recalculate(
//       currentBalance: account.balance,
//       tx: newTx,
//       oldTx: oldTx,
//       operation: OperationType.update,
//     );

//     await accountRepository.updateAccountBalance(
//       localUserId: localUserId,
//       remoteUid: remoteUid,
//       accountId: newTx.accountId,
//       newBalance: newBalance,
//     );
//   }
// }
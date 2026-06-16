import 'package:spend_io_app/features/account/data/models/account_model.dart';
import 'package:spend_io_app/features/wallet/domain/entities/wallet_summary_entity.dart';

abstract class WalletRepository {
  Future<WalletSummaryEntity> getSummary(int localUserId);

  Future<void> syncWithFirebase(int localUserId, String remoteUid);

  Future<bool> hasWalletData(int userId);

  Future<AccountModel> getAccount(String accountId);

  Future<void> updateAccount(AccountModel account);

  Future<void> updateAccountBalance({
    required int localUserId,
    required String remoteUid,
    required String accountId,
    required double newBalance,
  });
}

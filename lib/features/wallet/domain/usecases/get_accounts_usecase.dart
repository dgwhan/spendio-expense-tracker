import 'package:spend_io_app/features/wallet/domain/entities/account_entity.dart';
import 'package:spend_io_app/features/wallet/domain/repositories/wallet_repository.dart';

class GetAccountsUseCase {
  final WalletRepository repository;

  GetAccountsUseCase(this.repository);

  Future<List<AccountEntity>> call(int localUserId, String remoteUid, {bool forceSync = false}) {
    return repository.getAccounts(localUserId, remoteUid, forceSync: forceSync);
  }
}

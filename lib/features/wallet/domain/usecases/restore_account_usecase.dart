import 'package:spend_io_app/features/wallet/domain/repositories/wallet_repository.dart';

class RestoreAccountUseCase {
  final WalletRepository repository;

  RestoreAccountUseCase(this.repository);

  Future<void> call(int localUserId, String remoteUid, String accountId) {
    return repository.restoreAccount(localUserId, remoteUid, accountId);
  }
}

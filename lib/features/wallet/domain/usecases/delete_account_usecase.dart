import 'package:spend_io_app/features/wallet/domain/repositories/wallet_repository.dart';

class DeleteAccountUseCase {
  final WalletRepository repository;

  DeleteAccountUseCase(this.repository);

  Future<void> call(int localUserId, String remoteUid, String accountId) {
    return repository.deleteAccount(localUserId, remoteUid, accountId);
  }
}

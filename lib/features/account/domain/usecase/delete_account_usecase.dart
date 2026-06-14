import 'package:spend_io_app/features/account/domain/repositories/account_repository.dart';

class DeleteAccountUseCase {
  final AccountRepository repository;

  DeleteAccountUseCase(this.repository);

  Future<void> call(int localUserId, String remoteUid, String accountId) {
    return repository.deleteAccount(localUserId, remoteUid, accountId);
  }
}

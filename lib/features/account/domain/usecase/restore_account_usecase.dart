import 'package:spend_io_app/features/account/domain/repositories/account_repository.dart';

class RestoreAccountUseCase {
  final AccountRepository repository;

  RestoreAccountUseCase(this.repository);

  Future<void> call(int localUserId, String remoteUid, String accountId) {
    return repository.restoreAccount(localUserId, remoteUid, accountId);
  }
}

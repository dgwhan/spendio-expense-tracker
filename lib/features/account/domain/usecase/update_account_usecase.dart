import 'package:spend_io_app/features/account/domain/entities/account_entity.dart';
import 'package:spend_io_app/features/account/domain/repositories/account_repository.dart';

class UpdateAccountUseCase {
  final AccountRepository repository;

  UpdateAccountUseCase(this.repository);

  Future<void> call(int localUserId, String remoteUid, AccountEntity account) {
    return repository.updateAccount(localUserId, remoteUid, account);
  }
}

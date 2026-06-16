import 'package:spend_io_app/features/account/domain/entities/account_entity.dart';
import 'package:spend_io_app/features/account/domain/repositories/account_repository.dart';

class GetAccountsUseCase {
  final AccountRepository repository;

  GetAccountsUseCase(this.repository);

  Future<List<AccountEntity>> call(
    int localUserId,
    String remoteUid, {
    bool forceSync = false,
  }) {
    return repository.getAccounts(
      localUserId,
      remoteUid,
      forceSync: forceSync,
    );
  }
}

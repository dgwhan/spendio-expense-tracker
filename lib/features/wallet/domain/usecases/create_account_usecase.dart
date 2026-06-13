import 'package:spend_io_app/features/wallet/domain/entities/account_entity.dart';
import 'package:spend_io_app/features/wallet/domain/repositories/wallet_repository.dart';

class CreateAccountUseCase {
  final WalletRepository repository;

  CreateAccountUseCase(this.repository);

  Future<void> call(int localUserId, String remoteUid, AccountEntity account) {
    return repository.createAccount(localUserId, remoteUid, account);
  }
}

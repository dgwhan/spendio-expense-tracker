import 'package:spend_io_app/features/wallet/domain/repositories/wallet_repository.dart';

class CheckWalletInitializationUseCase {
  final WalletRepository repository;

  CheckWalletInitializationUseCase(this.repository);

  Future<bool> call(int userId) async {
    return repository.hasWalletData(userId);
  }
}

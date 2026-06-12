import 'package:spend_io_app/features/wallet/domain/entities/wallet_summary_entity.dart';
import 'package:spend_io_app/features/wallet/domain/repositories/wallet_repository.dart';

class GetWalletSummaryUseCase {
  final WalletRepository repository;

  GetWalletSummaryUseCase(this.repository);

  Future<WalletSummaryEntity> call(int localUserId) {
    return repository.getSummary(localUserId);
  }
}

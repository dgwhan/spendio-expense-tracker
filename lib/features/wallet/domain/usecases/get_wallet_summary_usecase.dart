import 'package:spend_io_app/features/wallet/domain/repositories/wallet_repository.dart';
import 'package:spend_io_app/features/wallet/domain/wallet_summary_result.dart';

class GetWalletSummaryUseCase {
  final WalletRepository repository;

  GetWalletSummaryUseCase(this.repository);

  Future<WalletSummaryResult> call(int localUserId) {
    return repository.getSummary(localUserId);
  }
}

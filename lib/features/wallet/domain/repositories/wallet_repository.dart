import 'package:spend_io_app/features/wallet/domain/wallet_summary_result.dart';

abstract class WalletRepository {
  Future<WalletSummaryResult> getSummary(int localUserId);

  Future<bool> hasWalletData(int userId);
}

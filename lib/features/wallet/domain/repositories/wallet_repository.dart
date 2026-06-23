import 'package:spend_io_app/features/wallet/domain/wallet_summary_result.dart';

abstract class WalletRepository {
  Future<WalletSummaryResult> getSummary(int localUserId, {String? preferredCurrencyCode});

  Future<bool> hasWalletData(int userId);
}

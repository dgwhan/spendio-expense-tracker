import 'package:spend_io_app/features/wallet/domain/entities/wallet_summary_entity.dart';

abstract class WalletRepository {
  /// Lấy thông tin tổng quan ví tài chính
  Future<WalletSummaryEntity> getSummary(int localUserId);

  /// Đồng bộ hóa thủ công với Firebase Firestore
  Future<void> syncWithFirebase(int localUserId, String remoteUid);

  Future<bool> hasWalletData(int userId);
}

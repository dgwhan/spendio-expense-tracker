import 'package:flutter/foundation.dart';
import 'package:spend_io_app/features/wallet/domain/repositories/wallet_repository.dart';

class WalletSyncService {
  final WalletRepository repository;

  WalletSyncService(this.repository);

  Future<void> syncIfNeeded(int userId, String remoteUid) async {
    if (remoteUid.isEmpty) return;

    try {
      debugPrint('[WalletSync] syncing user $userId');
    } catch (e) {
      debugPrint('[WalletSync] failed: $e');
    }
  }
}

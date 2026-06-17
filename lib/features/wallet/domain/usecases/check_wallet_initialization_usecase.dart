import 'package:flutter/foundation.dart';
import 'package:spend_io_app/features/wallet/domain/repositories/wallet_repository.dart';

class CheckWalletInitializationUseCase {
  final WalletRepository repository;

  CheckWalletInitializationUseCase(this.repository);

  Future<bool> call(int userId, String remoteUid) async {
    if (remoteUid.isNotEmpty) {
      repository.syncWithFirebase(userId, remoteUid).catchError((e) {
        debugPrint('[CheckWalletInit] Đồng bộ Firebase ngầm thất bại: $e');
      });
    }

    return repository.hasWalletData(userId);
  }
}

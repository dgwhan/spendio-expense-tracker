import 'package:flutter/foundation.dart';
import 'package:spend_io_app/features/account/data/datasource/account_local_data_source.dart';
import 'package:spend_io_app/features/account/data/datasource/account_remote_data_source.dart';
import 'package:spend_io_app/features/account/data/models/account_model.dart';
import 'package:spend_io_app/features/account/domain/entities/account_entity.dart';
import 'package:spend_io_app/features/account/domain/repositories/account_repository.dart';

class AccountRepositoryImpl implements AccountRepository {
  final AccountLocalDataSource localDataSource;
  final AccountRemoteDataSource remoteDataSource;

  AccountRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  @override
  Future<List<AccountEntity>> getAccounts(int localUserId, String remoteUid,
      {bool forceSync = false}) async {
    final localAccounts = await localDataSource.getAccounts(localUserId);

    final activeLocalAccounts = localAccounts
        .where((a) => a.deletedAt == null && a.name.trim().isNotEmpty)
        .toList();

    if (remoteUid.trim().isEmpty) {
      return activeLocalAccounts.map((m) => m.toEntity()).toList();
    }

    if (forceSync) {
      await _syncWithFirebase(localUserId, remoteUid);
      final refreshed = await localDataSource.getAccounts(localUserId);
      return refreshed
          .where((a) => a.deletedAt == null && a.name.trim().isNotEmpty)
          .map((m) => m.toEntity())
          .toList();
    } else {
      _syncWithFirebase(localUserId, remoteUid).catchError((e) {
        debugPrint('Lỗi đồng bộ ngầm wallets: $e');
      });
      return activeLocalAccounts.map((m) => m.toEntity()).toList();
    }
  }

  @override
  Future<void> saveAccount(
      int localUserId, String remoteUid, AccountEntity account) async {
    if (remoteUid.trim().isEmpty) return;
    final model = AccountModel.fromEntity(account);
    await localDataSource.saveAccount(localUserId, model);
    try {
      await remoteDataSource
          .saveAccount(remoteUid, model)
          .timeout(const Duration(seconds: 4));
    } catch (e) {
      debugPrint('Đang offline, lưu ví tạm thời vào local: $e');
    }
  }

  @override
  Future<void> createAccount(
      int localUserId, String remoteUid, AccountEntity account) async {
    final model = AccountModel.fromEntity(account);
    await localDataSource.createAccount(localUserId, model);
    if (remoteUid.trim().isEmpty) return;
    try {
      await remoteDataSource
          .saveAccount(remoteUid, model)
          .timeout(const Duration(seconds: 4));
    } catch (e) {
      debugPrint('Đang offline, tạo ví ở local: $e');
    }
  }

  @override
  Future<void> updateAccount(
      int localUserId, String remoteUid, AccountEntity account) async {
    final model = AccountModel.fromEntity(account);
    await localDataSource.updateAccount(localUserId, model);
    if (remoteUid.trim().isEmpty) return;
    try {
      await remoteDataSource
          .saveAccount(remoteUid, model)
          .timeout(const Duration(seconds: 4));
    } catch (e) {
      debugPrint('Đang offline, cập nhật ví ở local: $e');
    }
  }

  @override
  Future<void> deleteAccount(
      int localUserId, String remoteUid, String accountId) async {
    await localDataSource.softDeleteAccount(accountId);
    if (remoteUid.trim().isEmpty) return;
    try {
      final localAccounts = await localDataSource.getAccounts(localUserId);
      final deletedAccount = localAccounts.firstWhere((a) => a.id == accountId);
      await remoteDataSource
          .saveAccount(remoteUid, deletedAccount)
          .timeout(const Duration(seconds: 4));
    } catch (e) {
      debugPrint('Đang offline, xóa mềm ví tạm thời ở local: $e');
    }
  }

  @override
  Future<void> restoreAccount(
      int localUserId, String remoteUid, String accountId) async {
    await localDataSource.restoreAccount(accountId);
    if (remoteUid.trim().isEmpty) return;
    try {
      final localAccounts = await localDataSource.getAccounts(localUserId);
      final restoredAccount =
          localAccounts.firstWhere((a) => a.id == accountId);
      await remoteDataSource
          .saveAccount(remoteUid, restoredAccount)
          .timeout(const Duration(seconds: 4));
    } catch (e) {
      debugPrint('Đang offline, khôi phục ví tạm thời ở local: $e');
    }
  }

  @override
  Future<bool> hasAccounts(int userId) {
    return localDataSource.hasAccounts(userId);
  }

  Future<void> _syncWithFirebase(int localUserId, String remoteUid) async {
    if (remoteUid.trim().isEmpty) {
      debugPrint('[Sync Log] Aborted: remoteUid is empty.');
      return;
    }

    debugPrint(
        '[Sync Log] STARTING SYNC for Local ID: $localUserId | Remote UID: $remoteUid');

    try {
      final localWallets = await localDataSource.getAccounts(localUserId);
      final remoteWallets = await remoteDataSource.getAccounts(remoteUid);

      debugPrint(
          '[Sync Log] Local DB fetched: ${localWallets.length} wallets.');
      for (var lw in localWallets) {
        debugPrint(
            '   - Local Wallet: ID=${lw.id}, Name="${lw.name}", UserID=${lw.userId}, Deleted=${lw.deletedAt}');
      }

      debugPrint(
          '☁️ [Sync Log] Firestore fetched: ${remoteWallets.length} wallets.');
      for (var rw in remoteWallets) {
        debugPrint(
            '   - Remote Wallet: ID=${rw.id}, Name="${rw.name}", Deleted=${rw.deletedAt}');
      }

      final Map<String, AccountModel> localMap = {
        for (var w in localWallets) w.id: w
      };
      final cleanRemoteWallets = remoteWallets
          .where((w) => w.id.trim().isNotEmpty && w.name.trim().isNotEmpty)
          .toList();
      final Map<String, AccountModel> remoteMap = {
        for (var w in cleanRemoteWallets) w.id: w
      };

      // 1. Duyệt Remote check tải về Local hoặc cập nhật chéo dữ liệu mới nhất
      for (final remoteWallet in cleanRemoteWallets) {
        final localWallet = localMap[remoteWallet.id];
        if (localWallet == null) {
          if (remoteWallet.deletedAt == null) {
            debugPrint(
                '📥 [Sync Log] Downloading new wallet from Cloud to Local SQLite: ID=${remoteWallet.id}');
            await localDataSource.saveAccount(localUserId, remoteWallet);
          }
        } else {
          if (remoteWallet.updatedAt.isAfter(localWallet.updatedAt)) {
            debugPrint(
                '[Sync Log] Cloud version is newer. Updating Local SQLite: ID=${remoteWallet.id}');
            await localDataSource.saveAccount(localUserId, remoteWallet);
          } else if (localWallet.updatedAt.isAfter(remoteWallet.updatedAt)) {
            debugPrint(
                '[Sync Log] Local version is newer. Uploading to Firestore: ID=${localWallet.id}');
            await remoteDataSource.saveAccount(remoteUid, localWallet);
          }
        }
      }

      // 2. Duyệt Local để upload các ví tạo Offline / Onboarding lên Server
      for (final localWallet in localWallets) {
        if (!remoteMap.containsKey(localWallet.id)) {
          if (localWallet.id.trim().isNotEmpty &&
              localWallet.name.trim().isNotEmpty &&
              localWallet.deletedAt == null) {
            debugPrint(
                '[Sync Log] TRIGGERING UPLOAD! Local wallet missing on Cloud: ID=${localWallet.id}, Name="${localWallet.name}"');
            await remoteDataSource.saveAccount(remoteUid, localWallet);
          } else {
            debugPrint(
                '[Sync Log] IGNORED UPLOAD (Filtered out): ID=${localWallet.id}, Name="${localWallet.name}", Deleted=${localWallet.deletedAt}');
          }
        }
      }

      debugPrint('[Sync Log] SYNC COMPLETED SUCCESSFULLY.');
    } catch (e) {
      debugPrint('[Sync Log] CRITICAL ERROR DURING SYNC: $e');
    }
  }
}

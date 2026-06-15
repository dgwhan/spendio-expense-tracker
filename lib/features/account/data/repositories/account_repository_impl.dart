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
    // Luôn trả về từ SQLite cục bộ trước để giao diện tải tức thì
    final localAccounts = await localDataSource.getAccounts(localUserId);
    final activeLocalAccounts =
        localAccounts.where((a) => a.deletedAt == null).toList();

    if (forceSync) {
      await _syncWithFirebase(localUserId, remoteUid);
      final refreshed = await localDataSource.getAccounts(localUserId);
      return refreshed.where((a) => a.deletedAt == null).toList();
    } else {
      // Gọi đồng bộ ngầm (background sync) không chặn luồng hiển thị
      _syncWithFirebase(localUserId, remoteUid).catchError((e) {
        debugPrint('Lỗi đồng bộ ngầm wallets: $e');
      });
      return activeLocalAccounts;
    }
  }

  @override
  Future<void> saveAccount(
      int localUserId, String remoteUid, AccountEntity account) async {
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
    // 1. Xóa mềm SQLite
    await localDataSource.softDeleteAccount(accountId);

    // 2. Lấy model đã cập nhật để đồng bộ lên Firestore
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
    // 1. Khôi phục SQLite
    await localDataSource.restoreAccount(accountId);

    // 2. Lấy model đã cập nhật để đồng bộ lên Firestore
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
    try {
      final localWallets = await localDataSource.getAccounts(localUserId);
      final remoteWallets = await remoteDataSource.getAccounts(remoteUid);

      final Map<String, AccountModel> localMap = {
        for (var w in localWallets) w.id: w
      };
      final Map<String, AccountModel> remoteMap = {
        for (var w in remoteWallets) w.id: w
      };

      // 1. Duyệt remote check tải về local hoặc cập nhật chéo
      for (final remoteWallet in remoteWallets) {
        final localWallet = localMap[remoteWallet.id];
        if (localWallet == null) {
          await localDataSource.saveAccount(localUserId, remoteWallet);
        } else {
          if (remoteWallet.updatedAt.isAfter(localWallet.updatedAt)) {
            await localDataSource.saveAccount(localUserId, remoteWallet);
          } else if (localWallet.updatedAt.isAfter(remoteWallet.updatedAt)) {
            await remoteDataSource.saveAccount(remoteUid, localWallet);
          }
        }
      }

      // 2. Duyệt local để upload dữ liệu tạo offline lên remote
      for (final localWallet in localWallets) {
        if (!remoteMap.containsKey(localWallet.id)) {
          await remoteDataSource.saveAccount(remoteUid, localWallet);
        }
      }
    } catch (e) {
      debugPrint(
          'Đang offline, không thể đồng bộ hóa wallets với Firestore: $e');
    }
  }
}

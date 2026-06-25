import 'package:flutter/foundation.dart';
import 'package:spend_io_app/features/account/data/datasource/account_local_data_source.dart';
import 'package:spend_io_app/features/account/data/datasource/account_remote_data_source.dart';
import 'package:spend_io_app/features/account/data/models/account_model.dart';
import 'package:spend_io_app/features/account/data/services/account_sync_service.dart';
import 'package:spend_io_app/features/account/domain/entities/account_entity.dart';
import 'package:spend_io_app/features/account/domain/repositories/account_repository.dart';

class AccountRepositoryImpl implements AccountRepository {
  final AccountLocalDataSource localDataSource;
  final AccountRemoteDataSource remoteDataSource;
  final AccountSyncService accountSyncService;

  AccountRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.accountSyncService,
  });

  @override
  Future<List<AccountEntity>> getAccounts(int localUserId, String remoteUid,
      {bool forceSync = false}) async {
    // 1. Đọc dữ liệu local hiện tại trước
    var localAccounts = await localDataSource.getAccounts(localUserId);

    // 🌟 2. CORE SYNC CRITERIA: Nếu local trống HOẶC ép buộc đồng bộ (forceSync)
    if ((localAccounts.isEmpty || forceSync) && remoteUid.trim().isNotEmpty) {
      await accountSyncService.sync(localUserId, remoteUid);
      localAccounts = await localDataSource.getAccounts(localUserId);
    }

    // 3. Trả về kết quả sạch sau lọc trùng/xóa mềm
    return localAccounts
        .where((a) => a.deletedAt == null && a.name.trim().isNotEmpty)
        .map((m) => m.toEntity())
        .toList();
  }

  @override
  Future<void> saveAccount(
      int localUserId, String remoteUid, AccountEntity account) async {
    final model = AccountModel.fromEntity(account);
    await localDataSource.saveAccount(localUserId, model);

    if (remoteUid.trim().isEmpty) return;
    try {
      await remoteDataSource
          .saveAccount(remoteUid, model)
          .timeout(const Duration(seconds: 4));
    } catch (e) {
      debugPrint('[Account Repo]: Cloud backup delayed (Offline mode active).');
    }
  }

  @override
  Future<void> createAccount(
      int localUserId, String remoteUid, AccountEntity account) async {
    if (localUserId <= 0 || account.userId <= 0) {
      debugPrint(
          '[Account Repository Core]: Chặn đứng hành vi tạo ví lỗi! "localUserId" hoặc "account.userId" đang bị bằng 0.');
      throw ArgumentError(
          'Cannot create a wallet for an unauthenticated or invalid user identity (ID = 0).');
    }

    final model =
        AccountModel.fromEntity(account).copyWith(userId: localUserId);

    await localDataSource.createAccount(localUserId, model);

    if (remoteUid.trim().isEmpty) return;
    try {
      await remoteDataSource
          .saveAccount(remoteUid, model)
          .timeout(const Duration(seconds: 4));
    } catch (e) {
      debugPrint(
          '[Account Repo]: Device offline. Account creation backup delayed.');
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
      debugPrint('[Account Repo]: Account update backup delayed.');
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
      debugPrint('[Account Repo]: Soft-delete cloud mirror backup delayed.');
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
      debugPrint('[Account Repo]: Restore cloud mirror backup delayed.');
    }
  }

  @override
  Future<bool> hasAccounts(int userId) {
    return localDataSource.hasAccounts(userId);
  }
}

import 'package:flutter/material.dart';
import 'package:spend_io_app/features/account/data/datasource/account_local_data_source.dart';
import 'package:spend_io_app/features/account/data/datasource/account_remote_data_source.dart';

class AccountSyncService {
  final AccountLocalDataSource localDataSource;
  final AccountRemoteDataSource remoteDataSource;

  AccountSyncService({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  Future<void> sync(int localUserId, String remoteUid) async {
    if (remoteUid.trim().isEmpty) return;

    try {
      final localAccounts = await localDataSource.getAccounts(localUserId);
      final remoteAccounts = await remoteDataSource.getAccounts(remoteUid);

      final localMap = {for (var a in localAccounts) a.id: a};
      final remoteMap = {for (var a in remoteAccounts) a.id: a};

      // =========================
      // 1. PULL (REMOTE → LOCAL)
      // =========================
      for (final remote in remoteAccounts) {
        if (remote.id.trim().isEmpty) continue;

        final local = localMap[remote.id];

        // missing locally → insert
        if (local == null) {
          if (remote.deletedAt == null) {
            await localDataSource.saveAccount(localUserId, remote);
          }
          continue;
        }

        // remote is newer overwrite metadata only
        if (remote.updatedAt.isAfter(local.updatedAt)) {
          final merged = remote.copyWith(
            balance: local.balance,
          );

          await localDataSource.saveAccount(localUserId, merged);
        }
      }

      // =========================
      // 2. PUSH (LOCAL → REMOTE)
      // =========================
      for (final local in localAccounts) {
        if (local.id.trim().isEmpty) continue;

        final remote = remoteMap[local.id];

        // new local → push
        if (remote == null) {
          if (local.deletedAt == null) {
            await remoteDataSource.saveAccount(remoteUid, local);
          }
          continue;
        }

        // local newer → push metadata
        if (local.updatedAt.isAfter(remote.updatedAt)) {
          await remoteDataSource.saveAccount(remoteUid, local);
        }
      }

      debugPrint('[AccountSync]: Sync completed');
    } catch (e) {
      debugPrint('[AccountSync]: Sync failed: $e');
    }
  }
}

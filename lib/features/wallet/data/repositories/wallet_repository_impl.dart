import 'package:flutter/foundation.dart';
import 'package:spend_io_app/features/wallet/data/datasources/wallet_local_data_source.dart';
import 'package:spend_io_app/features/wallet/data/datasources/wallet_remote_data_source.dart';
import 'package:spend_io_app/features/account/data/models/account_model.dart';
import 'package:spend_io_app/features/wallet/data/models/saving_goal_model.dart';
import 'package:spend_io_app/features/wallet/domain/entities/wallet_summary_entity.dart';
import 'package:spend_io_app/features/wallet/domain/repositories/wallet_repository.dart';

class WalletRepositoryImpl implements WalletRepository {
  final WalletLocalDataSource localDataSource;
  final WalletRemoteDataSource remoteDataSource;

  WalletRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  // --------------------------------------------------------------------------
  // SUMMARY
  // --------------------------------------------------------------------------

  @override
  Future<WalletSummaryEntity> getSummary(int localUserId) async {
    final accounts = await localDataSource.getAccounts(localUserId);
    final activeAccounts = accounts.where((a) => a.deletedAt == null).toList();
    final goals = await localDataSource.getGoals(localUserId);
    final categories = await localDataSource.getCategories(localUserId);

    return WalletSummaryEntity(
      totalAssets: activeAccounts.fold(0.0, (sum, acc) => sum + acc.balance),
      monthlyBudget: categories.fold(0.0, (sum, cat) => sum + cat.budget),
      totalSaved: goals.fold(0.0, (sum, goal) => sum + goal.currentAmount),
      activeGoals: goals.length,
    );
  }

  // --------------------------------------------------------------------------
  // TARGETED BALANCE UPDATE
  // Called exclusively by UpdateWalletBalance use case after a transaction.
  // Does NOT go through the sync pipeline — bypasses Sync Guard entirely.
  // --------------------------------------------------------------------------

  @override
  Future<void> updateAccountBalance({
    required int localUserId,
    required String remoteUid,
    required String accountId,
    required double newBalance,
  }) async {
    // Step 1: Read current record from SQLite.
    final allAccounts = await localDataSource.getAccounts(localUserId);
    final account = allAccounts.firstWhere(
      (a) => a.id == accountId,
      orElse: () => throw StateError(
          '[WalletRepo] updateAccountBalance: account $accountId not found.'),
    );

    final updated = account.copyWith(
      balance: newBalance,
      updatedAt: DateTime.now(),
    );

    // Step 2: Persist to SQLite via targeted UPDATE (ConflictAlgorithm.replace
    // is handled inside AccountLocalDataSourceImpl.updateAccount).
    await localDataSource.updateAccount(localUserId, updated);
    debugPrint('[WalletRepo] Balance updated locally — account: $accountId, '
        'new balance: $newBalance');

    // Step 3: Push balance patch to Firestore.
    // updateAccountBalance on the remote datasource uses .update() (not .set()),
    // so only the balance field is overwritten. Network failures are caught
    // inside the remote datasource and logged; the app remains functional
    // in offline mode via SQLite.
    if (remoteUid.trim().isNotEmpty) {
      await remoteDataSource.updateAccountBalance(
        remoteUid,
        accountId,
        newBalance,
      );
    }
  }

  // --------------------------------------------------------------------------
  // FULL SYNC PIPELINE
  // Handles metadata sync and new-device bootstrap.
  // Sync Guard here is scoped to INSERT paths only — UPDATE paths
  // are guarded by ID-existence checks, not type-based filtering.
  // --------------------------------------------------------------------------

  @override
  Future<void> syncWithFirebase(int localUserId, String remoteUid) async {
    if (remoteUid.trim().isEmpty) {
      debugPrint('[Wallet Sync] Aborted — remoteUid is empty.');
      return;
    }

    debugPrint(
        '[Wallet Sync] Starting synchronization pipeline for user: $localUserId');

    try {
      await _syncAccounts(localUserId, remoteUid);
      await _syncGoals(localUserId, remoteUid);

      debugPrint('[Wallet Sync] Pipeline completed successfully.');
    } catch (e) {
      debugPrint('[Wallet Sync] Network unstable or Firestore timeout. '
          'Offline mode active: $e');
    }
  }

  Future<void> _syncAccounts(int localUserId, String remoteUid) async {
    final localWallets = await localDataSource.getAccounts(localUserId);
    final remoteWallets = await remoteDataSource.getAccounts(remoteUid);

    // Build ID-keyed maps first. Duplicate filtering below applies only to
    // the INSERT path — records whose IDs already exist in the local map
    // are treated as updates and are never skipped.
    final Map<String, AccountModel> localMap = {
      for (var w in localWallets) w.id: w
    };
    final Map<String, AccountModel> remoteMap = {
      for (var w in remoteWallets) w.id: w
    };

    // Guard state: tracks whether a primary cash wallet has already been
    // inserted during THIS sync pass. Only blocks INSERT of a second cash
    // wallet when no local record with that ID exists yet.
    bool primaryCashInserted = false;

    // Remote -> Local
    for (final remoteWallet in remoteWallets) {
      if (remoteWallet.id.trim().isEmpty || remoteWallet.name.trim().isEmpty) {
        continue;
      }

      final localWallet = localMap[remoteWallet.id];

      if (localWallet == null) {
        // INSERT path — guard applies here.
        if (remoteWallet.deletedAt != null) continue;

        if (remoteWallet.type.name == 'cash') {
          if (primaryCashInserted) {
            debugPrint('[Wallet Sync Guard] Blocked INSERT of duplicate remote '
                'cash wallet (ID: ${remoteWallet.id}).');
            continue;
          }
          primaryCashInserted = true;
        }

        await localDataSource.saveAccount(localUserId, remoteWallet);
      } else {
        // UPDATE path — guard never applies; ID already exists locally.
        if (remoteWallet.deletedAt != null && localWallet.deletedAt == null) {
          // Remote soft-delete is authoritative.
          await localDataSource.saveAccount(localUserId, remoteWallet);
        } else if (remoteWallet.updatedAt.isAfter(localWallet.updatedAt)) {
          // Remote metadata wins; preserve local balance.
          await localDataSource.saveAccount(
            localUserId,
            remoteWallet.copyWith(balance: localWallet.balance),
          );
        } else if (localWallet.updatedAt.isAfter(remoteWallet.updatedAt)) {
          // Local metadata wins; push up to Firestore.
          await remoteDataSource.saveAccount(remoteUid, localWallet);
        }
      }
    }

    // Local -> Remote (bootstrap offline-created wallets)
    for (final localWallet in localWallets) {
      if (remoteMap.containsKey(localWallet.id)) continue;

      if (localWallet.id.trim().isEmpty ||
          localWallet.name.trim().isEmpty ||
          localWallet.deletedAt != null) {
        continue;
      }

      await remoteDataSource.saveAccount(remoteUid, localWallet);
    }
  }

  Future<void> _syncGoals(int localUserId, String remoteUid) async {
    final localGoals = await localDataSource.getGoals(localUserId);
    final remoteGoals = await remoteDataSource.getGoals(remoteUid);

    final Map<String, SavingGoalModel> localGoalsMap = {
      for (var g in localGoals) g.id: g
    };
    final Map<String, SavingGoalModel> remoteGoalsMap = {
      for (var g in remoteGoals) g.id: g
    };

    for (final remoteGoal in remoteGoals) {
      final localGoal = localGoalsMap[remoteGoal.id];
      if (localGoal == null) {
        await localDataSource.saveGoal(localUserId, remoteGoal);
      } else if (remoteGoal.updatedAt.isAfter(localGoal.updatedAt)) {
        await localDataSource.saveGoal(localUserId, remoteGoal);
      } else if (localGoal.updatedAt.isAfter(remoteGoal.updatedAt)) {
        await remoteDataSource.saveGoal(remoteUid, localGoal);
      }
    }

    for (final localGoal in localGoals) {
      if (!remoteGoalsMap.containsKey(localGoal.id)) {
        await remoteDataSource.saveGoal(remoteUid, localGoal);
      }
    }
  }

  // --------------------------------------------------------------------------
  // MISC
  // --------------------------------------------------------------------------

  @override
  Future<bool> hasWalletData(int userId) async {
    final accounts = await localDataSource.hasAccounts(userId);
    final goals = await localDataSource.hasGoals(userId);
    final categories = await localDataSource.hasCategories(userId);
    return accounts || goals || categories;
  }

  @override
  Future<AccountModel> getAccount(String accountId) async {
    // getAccounts requires a userId; passing 0 as a fallback is a known
    // limitation — replace with a dedicated getAccountById on the datasource
    // when available.
    final allAccounts = await localDataSource.getAccounts(0);
    return allAccounts.firstWhere(
      (a) => a.id == accountId,
      orElse: () =>
          throw StateError('[WalletRepo] getAccount: $accountId not found.'),
    );
  }

  @override
  Future<void> updateAccount(AccountModel account) async {
    // Full-model upsert used internally by the sync pipeline.
    // Do NOT call this from transaction use cases — use updateAccountBalance.
    await localDataSource.saveAccount(account.userId, account);
  }
}

extension DateTimeComparison on DateTime {
  bool isAtLeast(DateTime other) => isAfter(other) || isAtEqual(other);

  bool isAtEqual(DateTime other) =>
      millisecondsSinceEpoch == other.millisecondsSinceEpoch;
}

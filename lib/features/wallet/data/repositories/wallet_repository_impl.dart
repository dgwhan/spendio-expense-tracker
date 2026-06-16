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

  @override
  Future<WalletSummaryEntity> getSummary(int localUserId) async {
    final accounts = await localDataSource.getAccounts(localUserId);
    final activeAccounts = accounts.where((a) => a.deletedAt == null).toList();
    final goals = await localDataSource.getGoals(localUserId);

    final totalAssets =
        activeAccounts.fold(0.0, (sum, acc) => sum + acc.balance);
    final totalSaved = goals.fold(0.0, (sum, goal) => sum + goal.currentAmount);
    final activeGoals = goals.length;

    final categories = await localDataSource.getCategories(localUserId);
    final monthlyBudget = categories.fold(0.0, (sum, cat) => sum + cat.budget);

    return WalletSummaryEntity(
      totalAssets: totalAssets,
      monthlyBudget: monthlyBudget,
      totalSaved: totalSaved,
      activeGoals: activeGoals,
    );
  }

  @override
  Future<void> syncWithFirebase(int localUserId, String remoteUid) async {
    if (remoteUid.trim().isEmpty) {
      debugPrint('[Wallet Repo Sync]: Aborted. remoteUid is empty.');
      return;
    }

    debugPrint(
        '[Wallet Repo Sync]: STARTING synchronization pipeline for User ID: $localUserId');

    try {
      // ----------------------------------------------------
      // A. WALLET SYNCHRONIZATION WITH STRICT FINTECH MERGE
      // ----------------------------------------------------
      final localWallets = await localDataSource.getAccounts(localUserId);
      final remoteWallets = await remoteDataSource.getAccounts(remoteUid);

      // ─── RULE 1: Filter Duplicate Primary Cash Wallets ───
      final List<AccountModel> cleanLocalWallets = [];
      bool primaryCashLocalExists = false;

      for (var w in localWallets) {
        if (w.type.name == 'cash' && w.deletedAt == null) {
          if (primaryCashLocalExists) {
            debugPrint(
                '[Wallet Sync Guard]: Detected duplicated local primary cash wallet (ID: ${w.id}). Skipping to ensure uniqueness.');
            continue;
          }
          primaryCashLocalExists = true;
        }
        cleanLocalWallets.add(w);
      }

      final List<AccountModel> cleanRemoteWallets = [];
      bool primaryCashRemoteExists = false;

      for (var w in remoteWallets) {
        if (w.id.trim().isEmpty || w.name.trim().isEmpty) continue;

        if (w.type.name == 'cash' && w.deletedAt == null) {
          if (primaryCashRemoteExists) {
            debugPrint(
                '[Wallet Sync Guard]: Detected duplicated remote primary cash wallet (ID: ${w.id}). Skipping payload integration.');
            continue;
          }
          primaryCashRemoteExists = true;
        }
        cleanRemoteWallets.add(w);
      }

      final Map<String, AccountModel> localMap = {
        for (var w in cleanLocalWallets) w.id: w
      };
      final Map<String, AccountModel> remoteMap = {
        for (var w in cleanRemoteWallets) w.id: w
      };

      // 1. Process Remote Updates into Local Engine
      for (final remoteWallet in cleanRemoteWallets) {
        final localWallet = localMap[remoteWallet.id];

        if (localWallet == null) {
          if (remoteWallet.deletedAt == null) {
            await localDataSource.saveAccount(localUserId, remoteWallet);
          }
        } else {
          if (remoteWallet.deletedAt != null && localWallet.deletedAt == null) {
            // Soft-deletions on remote are authoritative over active local states
            await localDataSource.saveAccount(localUserId, remoteWallet);
          } else if (remoteWallet.updatedAt.isAfter(localWallet.updatedAt)) {
            // REMOTE WINS FOR METADATA ONLY: Preserve local balance at all costs
            final AccountModel mergedWallet = remoteWallet.copyWith(
              balance: localWallet.balance,
            );
            await localDataSource.saveAccount(localUserId, mergedWallet);
          } else if (localWallet.updatedAt.isAfter(remoteWallet.updatedAt)) {
            // LOCAL WINS FOR METADATA: Push local metadata changes safely up to Firestore
            final AccountModel mergedRemoteWallet = localWallet.copyWith(
              balance: localWallet.balance,
            );
            await remoteDataSource.saveAccount(remoteUid, mergedRemoteWallet);
          }
        }
      }

      // 2. Process Offline Local Entries up to Server Hub (Race-Condition & Floating-Point Protected)
      for (final localWallet in cleanLocalWallets) {
        final remoteWallet = remoteMap[localWallet.id];

        if (remoteWallet == null) {
          if (localWallet.id.trim().isNotEmpty &&
              localWallet.name.trim().isNotEmpty &&
              localWallet.deletedAt == null) {
            await remoteDataSource.saveAccount(remoteUid, localWallet);
          }
        } else {
          // 🔥 FINTECH SAFEGUARD: Safe absolute precision comparison (No float equality issues)
          final bool isBalanceIdentical =
              (localWallet.balance - remoteWallet.balance).abs() < 0.0001;

          if (localWallet.updatedAt.isAtLeast(remoteWallet.updatedAt) &&
              isBalanceIdentical) {
            await remoteDataSource.saveAccount(remoteUid, localWallet);
          }
        }
      }

      // ----------------------------------------------------
      // B. GOAL SYNCHRONIZATION PIPELINE
      // ----------------------------------------------------
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
        } else {
          if (remoteGoal.updatedAt.isAfter(localGoal.updatedAt)) {
            await localDataSource.saveGoal(localUserId, remoteGoal);
          } else if (localGoal.updatedAt.isAfter(remoteGoal.updatedAt)) {
            await remoteDataSource.saveGoal(remoteUid, localGoal);
          }
        }
      }

      for (final localGoal in localGoals) {
        if (!remoteGoalsMap.containsKey(localGoal.id)) {
          await remoteDataSource.saveGoal(remoteUid, localGoal);
        }
      }

      debugPrint(
          '[Wallet Repo Sync]: Synchronization pipeline completed successfully.');
    } catch (e) {
      debugPrint(
          '[Wallet Repo Sync] Network connection unstable or Firestore timeout. Fallback active: $e');
    }
  }

  @override
  Future<bool> hasWalletData(int userId) async {
    final accounts = await localDataSource.hasAccounts(userId);
    final goals = await localDataSource.hasGoals(userId);
    final categories = await localDataSource.hasCategories(userId);
    return accounts || goals || categories;
  }
}

extension DateTimeComparison on DateTime {
  bool isAtLeast(DateTime other) {
    return isAfter(other) || isAtEqual(other);
  }

  bool isAtEqual(DateTime other) {
    return millisecondsSinceEpoch == other.millisecondsSinceEpoch;
  }
}

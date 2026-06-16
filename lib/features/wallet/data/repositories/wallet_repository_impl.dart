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

    // Tính ngân sách từ tổng ngân sách các danh mục
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
      // A. ĐỒNG BỘ WALLETS (TÀI KHOẢN)
      // ----------------------------------------------------
      final localWallets = await localDataSource.getAccounts(localUserId);
      final remoteWallets = await remoteDataSource.getAccounts(remoteUid);

      final Map<String, AccountModel> localMap = {
        for (var w in localWallets) w.id: w
      };

      // Lọc sạch các ví trống hoặc không có thông tin hợp lệ từ phía Remote để tránh nạp đè lung tung
      final cleanRemoteWallets = remoteWallets
          .where((w) => w.id.trim().isNotEmpty && w.name.trim().isNotEmpty)
          .toList();
      final Map<String, AccountModel> remoteMap = {
        for (var w in cleanRemoteWallets) w.id: w
      };

      // 1. Duyệt remote check tải về local hoặc cập nhật chéo
      for (final remoteWallet in cleanRemoteWallets) {
        final localWallet = localMap[remoteWallet.id];
        if (localWallet == null) {
          if (remoteWallet.deletedAt == null) {
            await localDataSource.saveAccount(localUserId, remoteWallet);
          }
        } else {
          // Trùng ID -> So sánh mốc thời gian để đồng bộ nâng cấp
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
          if (localWallet.id.trim().isNotEmpty &&
              localWallet.name.trim().isNotEmpty &&
              localWallet.deletedAt == null) {
            await remoteDataSource.saveAccount(remoteUid, localWallet);
          }
        }
      }

      // ----------------------------------------------------
      // B. ĐỒNG BỘ GOALS (MỤC TIÊU TIẾT KIỆM) - GIỮ NGUYÊN 100% GỐC
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

import 'package:flutter/foundation.dart';
import 'package:spend_io_app/features/wallet/data/datasources/wallet_local_data_source.dart';
import 'package:spend_io_app/features/wallet/data/datasources/wallet_remote_data_source.dart';
import 'package:spend_io_app/features/wallet/data/models/account_model.dart';
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
    
    final totalAssets = activeAccounts.fold(0.0, (sum, acc) => sum + acc.balance);
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
    try {
      // ----------------------------------------------------
      // A. ĐỒNG BỘ WALLETS (TÀI KHOẢN)
      // ----------------------------------------------------
      final localWallets = await localDataSource.getAccounts(localUserId);
      final remoteWallets = await remoteDataSource.getAccounts(remoteUid);

      final Map<String, AccountModel> localMap = {for (var w in localWallets) w.id: w};
      final Map<String, AccountModel> remoteMap = {for (var w in remoteWallets) w.id: w};

      // 1. Duyệt remote check tải về local hoặc cập nhật chéo
      for (final remoteWallet in remoteWallets) {
        final localWallet = localMap[remoteWallet.id];
        if (localWallet == null) {
          // Chưa có ở local -> tải xuống
          await localDataSource.saveAccount(localUserId, remoteWallet);
        } else {
          // Trùng ID -> So sánh updatedAt
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

      // ----------------------------------------------------
      // B. ĐỒNG BỘ GOALS (MỤC TIÊU TIẾT KIỆM)
      // ----------------------------------------------------
      final localGoals = await localDataSource.getGoals(localUserId);
      final remoteGoals = await remoteDataSource.getGoals(remoteUid);

      final Map<String, SavingGoalModel> localGoalsMap = {for (var g in localGoals) g.id: g};
      final Map<String, SavingGoalModel> remoteGoalsMap = {for (var g in remoteGoals) g.id: g};

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
    } catch (e) {
      // Nuốt lỗi kết nối hoặc Firestore timeout để duy trì trải nghiệm Offline
      debugPrint('Đang offline, không thể đồng bộ hóa với Firestore: $e');
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

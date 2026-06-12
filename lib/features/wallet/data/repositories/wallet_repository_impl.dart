import 'package:flutter/foundation.dart';
import 'package:spend_io_app/features/wallet/data/datasource/wallet_local_data_source.dart';
import 'package:spend_io_app/features/wallet/data/datasource/wallet_remote_data_source.dart';
import 'package:spend_io_app/features/wallet/data/models/account_model.dart';
import 'package:spend_io_app/features/wallet/data/models/saving_goal_model.dart';
import 'package:spend_io_app/features/wallet/domain/entities/account_entity.dart';
import 'package:spend_io_app/features/wallet/domain/entities/saving_goal_entity.dart';
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
    final goals = await localDataSource.getGoals(localUserId);
    
    final totalAssets = accounts.fold(0.0, (sum, acc) => sum + acc.balance);
    final totalSaved = goals.fold(0.0, (sum, goal) => sum + goal.currentAmount);
    final activeGoals = goals.length;
    
    // Tính ngân sách từ tổng ngân sách các danh mục
    final categories = localDataSource.getCategories();
    final monthlyBudget = categories.fold(0.0, (sum, cat) => sum + cat.budget);

    return WalletSummaryEntity(
      totalAssets: totalAssets,
      monthlyBudget: monthlyBudget,
      totalSaved: totalSaved,
      activeGoals: activeGoals,
    );
  }

  @override
  Future<List<AccountEntity>> getAccounts(int localUserId, String remoteUid, {bool forceSync = false}) async {
    // Luôn trả về từ SQLite cục bộ trước để giao diện tải tức thì
    final localAccounts = await localDataSource.getAccounts(localUserId);

    if (forceSync) {
      await syncWithFirebase(localUserId, remoteUid);
      return await localDataSource.getAccounts(localUserId);
    } else {
      // Gọi đồng bộ ngầm (background sync) không chặn luồng hiển thị
      syncWithFirebase(localUserId, remoteUid).catchError((e) {
        debugPrint('Lỗi đồng bộ ngầm wallets: $e');
      });
      return localAccounts;
    }
  }

  @override
  Future<void> saveAccount(int localUserId, String remoteUid, AccountEntity account) async {
    final model = AccountModel.fromEntity(account);
    
    // 1. Lưu SQLite trước
    await localDataSource.saveAccount(localUserId, model);
    
    // 2. Đồng bộ Firestore từ xa
    try {
      await remoteDataSource.saveAccount(remoteUid, model).timeout(const Duration(seconds: 4));
    } catch (e) {
      debugPrint('Đang offline, lưu ví tạm thời vào local: $e');
    }
  }

  @override
  Future<void> deleteAccount(String remoteUid, String accountId) async {
    // 1. Xóa SQLite
    await localDataSource.deleteAccount(accountId);

    // 2. Xóa Firestore
    try {
      await remoteDataSource.deleteAccount(remoteUid, accountId).timeout(const Duration(seconds: 4));
    } catch (e) {
      debugPrint('Đang offline, xóa ví tạm thời ở local: $e');
    }
  }

  @override
  Future<List<SavingGoalEntity>> getGoals(int localUserId, String remoteUid, {bool forceSync = false}) async {
    final localGoals = await localDataSource.getGoals(localUserId);

    if (forceSync) {
      await syncWithFirebase(localUserId, remoteUid);
      return await localDataSource.getGoals(localUserId);
    } else {
      syncWithFirebase(localUserId, remoteUid).catchError((e) {
        debugPrint('Lỗi đồng bộ ngầm goals: $e');
      });
      return localGoals;
    }
  }

  @override
  Future<void> saveGoal(int localUserId, String remoteUid, SavingGoalEntity goal) async {
    final model = SavingGoalModel.fromEntity(goal);

    await localDataSource.saveGoal(localUserId, model);

    try {
      await remoteDataSource.saveGoal(remoteUid, model).timeout(const Duration(seconds: 4));
    } catch (e) {
      debugPrint('Đang offline, lưu mục tiêu tạm thời vào local: $e');
    }
  }

  @override
  Future<void> deleteGoal(String remoteUid, String goalId) async {
    await localDataSource.deleteGoal(goalId);

    try {
      await remoteDataSource.deleteGoal(remoteUid, goalId).timeout(const Duration(seconds: 4));
    } catch (e) {
      debugPrint('Đang offline, xóa mục tiêu tạm thời ở local: $e');
    }
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
}

import 'package:flutter/foundation.dart';
import 'package:spend_io_app/features/wallet/data/datasources/goal/goal_local_data_source.dart';
import 'package:spend_io_app/features/wallet/data/datasources/goal/goal_remote_data_source.dart';
import 'package:spend_io_app/features/wallet/data/models/saving_goal_model.dart';
import 'package:spend_io_app/features/wallet/domain/entities/saving_goal_entity.dart';
import 'package:spend_io_app/features/wallet/domain/repositories/saving_goal_repository.dart';

class SavingGoalRepositoryImpl implements SavingGoalRepository {
  final GoalLocalDataSource localDataSource;
  final GoalRemoteDataSource remoteDataSource;

  SavingGoalRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  @override
  Future<List<SavingGoalEntity>> getGoals(int localUserId, String remoteUid, {bool forceSync = false}) async {
    final localGoals = await localDataSource.getGoals(localUserId);

    if (forceSync) {
      await _syncWithFirebase(localUserId, remoteUid);
      return await localDataSource.getGoals(localUserId);
    } else {
      // Gọi đồng bộ ngầm (background sync) không chặn luồng hiển thị
      _syncWithFirebase(localUserId, remoteUid).catchError((e) {
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
  Future<bool> hasGoals(int userId) {
    return localDataSource.hasGoals(userId);
  }

  Future<void> _syncWithFirebase(int localUserId, String remoteUid) async {
    try {
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
      debugPrint('Đang offline, không thể đồng bộ hóa goals với Firestore: $e');
    }
  }
}

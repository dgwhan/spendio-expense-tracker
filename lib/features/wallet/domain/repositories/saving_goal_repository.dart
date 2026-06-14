import 'package:spend_io_app/features/wallet/domain/entities/saving_goal_entity.dart';

abstract class SavingGoalRepository {
  /// Lấy danh sách các mục tiêu tiết kiệm đang hoạt động
  Future<List<SavingGoalEntity>> getGoals(int localUserId, String remoteUid, {bool forceSync = false});

  /// Thêm/Cập nhật mục tiêu tiết kiệm
  Future<void> saveGoal(int localUserId, String remoteUid, SavingGoalEntity goal);

  /// Xóa mục tiêu tiết kiệm
  Future<void> deleteGoal(String remoteUid, String goalId);

  Future<bool> hasGoals(int userId);
}

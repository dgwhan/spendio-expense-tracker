import 'package:spend_io_app/features/wallet/domain/entities/account_entity.dart';
import 'package:spend_io_app/features/wallet/domain/entities/saving_goal_entity.dart';
import 'package:spend_io_app/features/wallet/domain/entities/wallet_summary_entity.dart';

abstract class WalletRepository {
  /// Lấy thông tin tổng quan ví tài chính
  Future<WalletSummaryEntity> getSummary(int localUserId);

  /// Lấy danh sách toàn bộ tài khoản/ví thành phần
  Future<List<AccountEntity>> getAccounts(int localUserId, String remoteUid, {bool forceSync = false});

  /// Thêm/Cập nhật tài khoản ví
  Future<void> saveAccount(int localUserId, String remoteUid, AccountEntity account);

  /// Xóa tài khoản ví
  Future<void> deleteAccount(String remoteUid, String accountId);

  /// Lấy danh sách các mục tiêu tiết kiệm đang hoạt động
  Future<List<SavingGoalEntity>> getGoals(int localUserId, String remoteUid, {bool forceSync = false});

  /// Thêm/Cập nhật mục tiêu tiết kiệm
  Future<void> saveGoal(int localUserId, String remoteUid, SavingGoalEntity goal);

  /// Xóa mục tiêu tiết kiệm
  Future<void> deleteGoal(String remoteUid, String goalId);

  /// Đồng bộ hóa thủ công với Firebase Firestore
  Future<void> syncWithFirebase(int localUserId, String remoteUid);
}

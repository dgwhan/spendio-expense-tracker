import 'package:spend_io_app/features/wallet/domain/entities/account_entity.dart';
import 'package:spend_io_app/features/wallet/domain/entities/saving_goal_entity.dart';
import 'package:spend_io_app/features/wallet/domain/entities/wallet_summary_entity.dart';
import 'package:spend_io_app/features/wallet/domain/entities/budget_category_entity.dart';

abstract class WalletRepository {
  /// Lấy thông tin tổng quan ví tài chính
  Future<WalletSummaryEntity> getSummary(int localUserId);

  /// Lấy danh sách toàn bộ tài khoản/ví thành phần
  Future<List<AccountEntity>> getAccounts(int localUserId, String remoteUid, {bool forceSync = false});

  /// Thêm/Cập nhật tài khoản ví (deprecated, sử dụng createAccount / updateAccount)
  Future<void> saveAccount(int localUserId, String remoteUid, AccountEntity account);

  /// Tạo tài khoản ví mới
  Future<void> createAccount(int localUserId, String remoteUid, AccountEntity account);

  /// Cập nhật tài khoản ví
  Future<void> updateAccount(int localUserId, String remoteUid, AccountEntity account);

  /// Xóa mềm tài khoản ví
  Future<void> deleteAccount(int localUserId, String remoteUid, String accountId);

  /// Khôi phục tài khoản ví đã xóa mềm
  Future<void> restoreAccount(int localUserId, String remoteUid, String accountId);

  /// Lấy danh sách các mục tiêu tiết kiệm đang hoạt động
  Future<List<SavingGoalEntity>> getGoals(int localUserId, String remoteUid, {bool forceSync = false});

  /// Thêm/Cập nhật mục tiêu tiết kiệm
  Future<void> saveGoal(int localUserId, String remoteUid, SavingGoalEntity goal);

  /// Xóa mục tiêu tiết kiệm
  Future<void> deleteGoal(String remoteUid, String goalId);

  /// Lấy danh sách danh mục ngân sách của người dùng
  Future<List<BudgetCategoryEntity>> getCategories(int localUserId);

  /// Tạo danh mục ngân sách mới
  Future<void> createCategory(int localUserId, BudgetCategoryEntity category);

  /// Cập nhật danh mục ngân sách
  Future<void> updateCategory(int localUserId, BudgetCategoryEntity category);

  /// Đồng bộ hóa thủ công với Firebase Firestore
  Future<void> syncWithFirebase(int localUserId, String remoteUid);
}

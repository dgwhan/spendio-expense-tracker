import 'package:spend_io_app/features/wallet/domain/entities/account_entity.dart';

abstract class AccountRepository {
  /// Lấy danh sách toàn bộ tài khoản/ví thành phần
  Future<List<AccountEntity>> getAccounts(int localUserId, String remoteUid, {bool forceSync = false});

  /// Thêm/Cập nhật tài khoản ví
  Future<void> saveAccount(int localUserId, String remoteUid, AccountEntity account);

  /// Tạo tài khoản ví mới
  Future<void> createAccount(int localUserId, String remoteUid, AccountEntity account);

  /// Cập nhật tài khoản ví
  Future<void> updateAccount(int localUserId, String remoteUid, AccountEntity account);

  /// Xóa mềm tài khoản ví
  Future<void> deleteAccount(int localUserId, String remoteUid, String accountId);

  /// Khôi phục tài khoản ví đã xóa mềm
  Future<void> restoreAccount(int localUserId, String remoteUid, String accountId);

  Future<bool> hasAccounts(int userId);
}

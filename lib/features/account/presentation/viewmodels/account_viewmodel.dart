import 'package:flutter/material.dart';
import 'package:spend_io_app/features/account/domain/entities/account_entity.dart';
import 'package:spend_io_app/features/account/domain/usecase/create_account_usecase.dart';
import 'package:spend_io_app/features/account/domain/usecase/delete_account_usecase.dart';
import 'package:spend_io_app/features/account/domain/usecase/get_accounts_usecase.dart';
import 'package:spend_io_app/features/account/domain/usecase/update_account_usecase.dart';
// 🔥 BỔ SUNG IMPORT: Để đọc dữ liệu profile cứu hộ
import 'package:spend_io_app/features/onboarding/domain/repositories/onboarding_repository.dart';

class AccountViewModel extends ChangeNotifier {
  final GetAccountsUseCase getAccountsUseCase;
  final CreateAccountUseCase createAccountUseCase;
  final UpdateAccountUseCase updateAccountUseCase;
  final DeleteAccountUseCase deleteAccountUseCase;

  AccountViewModel({
    required this.getAccountsUseCase,
    required this.createAccountUseCase,
    required this.updateAccountUseCase,
    required this.deleteAccountUseCase,
  });

  List<AccountEntity> _rawAccounts = [];
  bool _isLoading = false;

  bool _isCreatingAccount = false;
  bool _isUpdatingAccount = false;
  bool _isDeletingAccount = false;

  String? _createAccountError;
  String? _updateAccountError;
  String? _deleteAccountError;

  bool get isLoading => _isLoading;
  bool get isCreatingAccount => _isCreatingAccount;
  bool get isUpdatingAccount => _isUpdatingAccount;
  bool get isDeletingAccount => _isDeletingAccount;

  String? get createAccountError => _createAccountError;
  String? get updateAccountError => _updateAccountError;
  String? get deleteAccountError => _deleteAccountError;

  int? _lastLoadedUserId;

  String? _profileCurrency;

  List<AccountEntity> get accounts =>
      _rawAccounts.where((account) => account.deletedAt == null).toList();

  String? get userCurrency {
    final activeAccounts = accounts;
    if (activeAccounts.isNotEmpty) {
      return activeAccounts.first.currencyCode;
    }
    // Nếu chưa có ví (User mới), bốc thẳng mã tiền tệ lấy từ cấu hình User Profile dưới DB lên RAM
    return _profileCurrency;
  }

  /// Tải danh sách ví từ DB Local / Server
  Future<void> loadAccounts(
    int localId,
    String remoteUid, {
    bool forceRefresh = false,
    required OnboardingRepository onboardingRepo,
    required String userEmail,
  }) async {
    if (!forceRefresh &&
        _lastLoadedUserId == localId &&
        _rawAccounts.isNotEmpty) {
      return;
    }

    _isLoading = true;
    _lastLoadedUserId = localId;
    notifyListeners();

    try {
      // 1. Cứu hộ chặng đầu: Đồng bộ mã tiền tệ từ Profile User trước khi quét danh sách ví
      final profile = await onboardingRepo.getOnboarding(email: userEmail);
      if (profile != null) {
        _profileCurrency = profile.currencyCode;
      }

      // 2. Tải danh sách ví vật lý
      _rawAccounts = await getAccountsUseCase(localId, remoteUid);
    } catch (e) {
      debugPrint('Error loading accounts: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Dọn dẹp sạch vùng nhớ khi user đăng xuất
  void clearAccounts() {
    _rawAccounts = [];
    _lastLoadedUserId = null;
    _profileCurrency = null;
    notifyListeners();
  }

  /// Thêm tài khoản ví mới
  Future<bool> createAccount(
      int localId, String remoteUid, AccountEntity account,
      {required OnboardingRepository onboardingRepo,
      required String userEmail}) async {
    _isCreatingAccount = true;
    _createAccountError = null;
    notifyListeners();

    try {
      await createAccountUseCase(localId, remoteUid, account);
      await loadAccounts(localId, remoteUid,
          forceRefresh: true,
          onboardingRepo: onboardingRepo,
          userEmail: userEmail);
      return true;
    } catch (e) {
      _createAccountError = e.toString();
      debugPrint('Error creating account: $e');
      return false;
    } finally {
      _isCreatingAccount = false;
      notifyListeners();
    }
  }

  /// Cập nhật thông tin tài khoản ví
  Future<bool> updateAccount(
      int localId, String remoteUid, AccountEntity account,
      {required OnboardingRepository onboardingRepo,
      required String userEmail}) async {
    _isUpdatingAccount = true;
    _updateAccountError = null;
    notifyListeners();

    try {
      await updateAccountUseCase(localId, remoteUid, account);
      await loadAccounts(localId, remoteUid,
          forceRefresh: true,
          onboardingRepo: onboardingRepo,
          userEmail: userEmail);
      return true;
    } catch (e) {
      _updateAccountError = e.toString();
      debugPrint('Error updating account: $e');
      return false;
    } finally {
      _isUpdatingAccount = false;
      notifyListeners();
    }
  }

  /// Xóa tài khoản ví
  Future<void> deleteAccount(int localId, String remoteUid, String accountId,
      {required OnboardingRepository onboardingRepo,
      required String userEmail}) async {
    if (accountId.trim().isEmpty) {
      _deleteAccountError = "Invalid Account ID";
      return;
    }

    _isDeletingAccount = true;
    _deleteAccountError = null;

    final targetIndex = _rawAccounts.indexWhere((acc) => acc.id == accountId);
    AccountEntity? backupAccount;
    if (targetIndex != -1) {
      backupAccount = _rawAccounts[targetIndex];
      _rawAccounts[targetIndex] = _rawAccounts[targetIndex].copyWith(
        deletedAt: DateTime.now(),
      );
      notifyListeners();
    }

    try {
      await deleteAccountUseCase(localId, remoteUid, accountId);
      await loadAccounts(localId, remoteUid,
          forceRefresh: true,
          onboardingRepo: onboardingRepo,
          userEmail: userEmail);
    } catch (e) {
      _deleteAccountError = e.toString();
      debugPrint('Error deleting account: $e');

      if (backupAccount != null && targetIndex != -1) {
        _rawAccounts[targetIndex] = backupAccount;
        notifyListeners();
      }
    } finally {
      _isDeletingAccount = false;
      notifyListeners();
    }
  }
}

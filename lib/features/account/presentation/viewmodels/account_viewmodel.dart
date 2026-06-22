import 'package:flutter/material.dart';
import 'package:spend_io_app/features/account/domain/entities/account_entity.dart';
import 'package:spend_io_app/features/account/domain/usecase/create_account_usecase.dart';
import 'package:spend_io_app/features/account/domain/usecase/delete_account_usecase.dart';
import 'package:spend_io_app/features/account/domain/usecase/get_accounts_usecase.dart';
import 'package:spend_io_app/features/account/domain/usecase/update_account_usecase.dart';

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
  String? _fallbackProfileCurrency;

  List<AccountEntity> get accounts =>
      _rawAccounts.where((account) => account.deletedAt == null).toList();

  String? get userCurrency {
    final activeAccounts = accounts;
    if (activeAccounts.isNotEmpty) {
      return activeAccounts.first.currencyCode;
    }
    return _fallbackProfileCurrency;
  }

  void setFallbackCurrency(String currencyCode) {
    if (currencyCode.trim().isEmpty) return;
    _fallbackProfileCurrency = currencyCode;
    notifyListeners();
  }

  Future<void> loadAccounts(
    int localId,
    String remoteUid, {
    bool forceRefresh = false,
  }) async {
    if (localId <= 0) {
      debugPrint(
          '[Account VM]: Load operation aborted. Invalid user session handle (localId: $localId).');
      return;
    }

    if (!forceRefresh &&
        _lastLoadedUserId == localId &&
        _rawAccounts.isNotEmpty) {
      return;
    }

    _isLoading = true;
    _lastLoadedUserId = localId;
    _createAccountError = null;
    notifyListeners();

    try {
      _rawAccounts = await getAccountsUseCase(localId, remoteUid);
    } catch (e) {
      debugPrint('[Account VM] Failed to resolve account data records: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearAccounts() {
    _rawAccounts = [];
    _lastLoadedUserId = null;
    _fallbackProfileCurrency = null;
    notifyListeners();
  }

  Future<bool> createAccount(
      int localId, String remoteUid, AccountEntity account) async {
    if (localId <= 0 || account.userId <= 0) {
      _createAccountError =
          "Critical Session Error: Cannot commit records using an unauthenticated ID (ID = 0).";
      debugPrint(
          '[Account VM]: Intercepted write action block. Forbidden anonymous foreign user key rejected.');
      notifyListeners();
      return false;
    }

    _isCreatingAccount = true;
    _createAccountError = null;
    notifyListeners();

    debugPrint('==================================================');
    debugPrint('[Account VM] STARTING ACCOUNT CREATION PROCESS');
    debugPrint('[Account VM] User Local ID: $localId');
    debugPrint('[Account VM] Account Payload Details:');
    debugPrint('   - Name: ${account.name}');
    debugPrint('   - Type: ${account.type}');
    debugPrint('   - Initial Balance: ${account.balance}');
    debugPrint('   - Currency: ${account.currencyCode}');
    debugPrint('==================================================');

    try {
      await createAccountUseCase(localId, remoteUid, account);
      await loadAccounts(localId, remoteUid, forceRefresh: true);

      debugPrint(
          '[Account VM] SUCCESS: Account "${account.name}" was successfully committed and reloaded.');
      return true;
    } catch (e) {
      _createAccountError = e.toString();

      debugPrint(
          '[Account VM] FAILURE: Execution error during account creation call.');
      debugPrint('[Account VM] Error Details: $e');
      return false;
    } finally {
      _isCreatingAccount = false;
      notifyListeners();
    }
  }

  Future<bool> updateAccount(
      int localId, String remoteUid, AccountEntity account) async {
    if (localId <= 0 || account.userId <= 0) {
      _updateAccountError =
          "Critical Session Error: Invalid modification reference identity context.";
      notifyListeners();
      return false;
    }

    _isUpdatingAccount = true;
    _updateAccountError = null;
    notifyListeners();

    try {
      await updateAccountUseCase(localId, remoteUid, account);
      await loadAccounts(localId, remoteUid, forceRefresh: true);
      return true;
    } catch (e) {
      _updateAccountError = e.toString();
      debugPrint(
          '[Account VM] Execution failure during record synchronization updates: $e');
      return false;
    } finally {
      _isUpdatingAccount = false;
      notifyListeners();
    }
  }

  Future<void> deleteAccount(
      int localId, String remoteUid, String accountId) async {
    if (localId <= 0 || accountId.trim().isEmpty) {
      _deleteAccountError =
          "Structural Mutation Denied: Invalid resource identity signature.";
      return;
    }

    _isDeletingAccount = true;
    _deleteAccountError = null;

    final targetIndex = _rawAccounts.indexWhere((acc) => acc.id == accountId);
    AccountEntity? optimisticRollbackBackup;

    if (targetIndex != -1) {
      optimisticRollbackBackup = _rawAccounts[targetIndex];
      _rawAccounts[targetIndex] = _rawAccounts[targetIndex].copyWith(
        deletedAt: DateTime.now(),
      );
      notifyListeners();
    }

    try {
      await deleteAccountUseCase(localId, remoteUid, accountId);
      await loadAccounts(localId, remoteUid, forceRefresh: true);
    } catch (e) {
      _deleteAccountError = e.toString();
      debugPrint(
          '[Account VM] Cloud storage replication rejected. Running optimistic UI rollback cache repair: $e');

      if (optimisticRollbackBackup != null && targetIndex != -1) {
        _rawAccounts[targetIndex] = optimisticRollbackBackup;
        notifyListeners();
      }
    } finally {
      _isDeletingAccount = false;
      notifyListeners();
    }
  }
}

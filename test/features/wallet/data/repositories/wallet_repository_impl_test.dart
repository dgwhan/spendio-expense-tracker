import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:spend_io_app/features/wallet/data/datasources/wallet_local_data_source.dart';
import 'package:spend_io_app/features/wallet/data/datasources/wallet_remote_data_source.dart';
import 'package:spend_io_app/features/wallet/data/models/account_model.dart';
import 'package:spend_io_app/features/wallet/data/models/saving_goal_model.dart';
import 'package:spend_io_app/features/wallet/data/models/budget_category_model.dart';
import 'package:spend_io_app/features/wallet/data/repositories/wallet_repository_impl.dart';
import 'package:spend_io_app/features/wallet/domain/entities/account_entity.dart';

// --------------------------------------------------------------------
// LỚP MOCK ĐỂ KIỂM THỬ KHÔNG PHỤ THUỘC VÀO SQLITE & FIRESTORE THẬT
// --------------------------------------------------------------------

class FakeLocalDataSource implements WalletLocalDataSource {
  final List<AccountModel> accountsDb = [];
  final List<SavingGoalModel> goalsDb = [];
  final List<BudgetCategoryModel> categoriesDb = [];

  @override
  Future<List<AccountModel>> getAccounts(int userId) async => accountsDb;

  @override
  Future<void> saveAccount(int userId, AccountModel account) async {
    accountsDb.removeWhere((a) => a.id == account.id);
    accountsDb.add(account);
  }

  @override
  Future<void> deleteAccount(String accountId) async {
    accountsDb.removeWhere((a) => a.id == accountId);
  }

  @override
  Future<void> createAccount(int userId, AccountModel account) async {
    accountsDb.removeWhere((a) => a.id == account.id);
    accountsDb.add(account);
  }

  @override
  Future<void> updateAccount(int userId, AccountModel account) async {
    accountsDb.removeWhere((a) => a.id == account.id);
    accountsDb.add(account);
  }

  @override
  Future<void> softDeleteAccount(String accountId) async {
    final index = accountsDb.indexWhere((a) => a.id == accountId);
    if (index != -1) {
      accountsDb[index] = accountsDb[index].copyWith(deletedAt: DateTime.now());
    }
  }

  @override
  Future<void> restoreAccount(String accountId) async {
    final index = accountsDb.indexWhere((a) => a.id == accountId);
    if (index != -1) {
      accountsDb[index] = accountsDb[index].copyWith(removeDeletedAt: true);
    }
  }

  @override
  Future<List<SavingGoalModel>> getGoals(int userId) async => goalsDb;

  @override
  Future<void> saveGoal(int userId, SavingGoalModel goal) async {
    goalsDb.removeWhere((g) => g.id == goal.id);
    goalsDb.add(goal);
  }

  @override
  Future<void> deleteGoal(String goalId) async {
    goalsDb.removeWhere((g) => g.id == goalId);
  }

  @override
  Future<List<BudgetCategoryModel>> getCategories(int userId) async => categoriesDb;

  @override
  Future<void> insertCategory(int userId, BudgetCategoryModel category) async {
    categoriesDb.removeWhere((c) => c.id == category.id);
    categoriesDb.add(category);
  }

  @override
  Future<void> updateCategory(int userId, BudgetCategoryModel category) async {
    categoriesDb.removeWhere((c) => c.id == category.id);
    categoriesDb.add(category);
  }

  @override
  Future<bool> hasAccounts(int userId) async {
    return accountsDb.where((a) => a.userId == userId && a.deletedAt == null).isNotEmpty;
  }

  @override
  Future<bool> hasGoals(int userId) async {
    return goalsDb.isNotEmpty;
  }

  @override
  Future<bool> hasCategories(int userId) async {
    return categoriesDb.isNotEmpty;
  }
}

class FakeRemoteDataSource implements WalletRemoteDataSource {
  final List<AccountModel> firestoreDb = [];
  final List<SavingGoalModel> firestoreGoalsDb = [];

  @override
  Future<List<AccountModel>> getAccounts(String userId) async => firestoreDb;

  @override
  Future<void> saveAccount(String userId, AccountModel account) async {
    firestoreDb.removeWhere((a) => a.id == account.id);
    firestoreDb.add(account);
  }

  @override
  Future<void> deleteAccount(String userId, String accountId) async {
    firestoreDb.removeWhere((a) => a.id == accountId);
  }

  @override
  Future<List<SavingGoalModel>> getGoals(String userId) async => firestoreGoalsDb;

  @override
  Future<void> saveGoal(String userId, SavingGoalModel goal) async {
    firestoreGoalsDb.removeWhere((g) => g.id == goal.id);
    firestoreGoalsDb.add(goal);
  }

  @override
  Future<void> deleteGoal(String userId, String goalId) async {
    firestoreGoalsDb.removeWhere((g) => g.id == goalId);
  }
}

void main() {
  late FakeLocalDataSource localDataSource;
  late FakeRemoteDataSource remoteDataSource;
  late WalletRepositoryImpl repository;

  setUp(() {
    localDataSource = FakeLocalDataSource();
    remoteDataSource = FakeRemoteDataSource();
    repository = WalletRepositoryImpl(
      localDataSource: localDataSource,
      remoteDataSource: remoteDataSource,
    );
  });

  group('WalletRepositoryImpl Sync Engine Tests', () {
    test('Nên tải ví cục bộ lên remote nếu chỉ tồn tại ở Local', () async {
      final offlineWallet = AccountModel(
        id: 'wallet_local_01',
        userId: 1,
        name: 'Offline Cash',
        type: AccountType.cash,
        balance: 100.0,
        icon: Icons.wallet,
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );
      localDataSource.accountsDb.add(offlineWallet);

      await repository.syncWithFirebase(1, 'remote_user_uid');

      expect(remoteDataSource.firestoreDb.length, 1);
      expect(remoteDataSource.firestoreDb.first.id, 'wallet_local_01');
      expect(remoteDataSource.firestoreDb.first.name, 'Offline Cash');
    });

    test('Nên tải ví từ remote xuống local nếu chỉ tồn tại ở Remote', () async {
      final remoteWallet = AccountModel(
        id: 'wallet_remote_01',
        userId: 1,
        name: 'Cloud Wallet',
        type: AccountType.bank,
        balance: 5000.0,
        icon: Icons.account_balance,
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );
      remoteDataSource.firestoreDb.add(remoteWallet);

      await repository.syncWithFirebase(1, 'remote_user_uid');

      expect(localDataSource.accountsDb.length, 1);
      expect(localDataSource.accountsDb.first.id, 'wallet_remote_01');
      expect(localDataSource.accountsDb.first.name, 'Cloud Wallet');
    });

    test('Nên cập nhật Local nếu Remote có updatedAt mới hơn', () async {
      final oldLocalWallet = AccountModel(
        id: 'wallet_trung_01',
        userId: 1,
        name: 'Tài khoản gốc',
        type: AccountType.eWallet,
        balance: 200.0,
        icon: Icons.wallet,
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );
      localDataSource.accountsDb.add(oldLocalWallet);

      final newRemoteWallet = AccountModel(
        id: 'wallet_trung_01',
        userId: 1,
        name: 'Tài khoản cập nhật trên Web',
        type: AccountType.eWallet,
        balance: 250.0,
        icon: Icons.wallet,
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 2),
      );
      remoteDataSource.firestoreDb.add(newRemoteWallet);

      await repository.syncWithFirebase(1, 'remote_user_uid');

      expect(localDataSource.accountsDb.first.name, 'Tài khoản cập nhật trên Web');
      expect(localDataSource.accountsDb.first.balance, 250.0);
    });

    test('Nên cập nhật Remote nếu Local có updatedAt mới hơn', () async {
      final newLocalWallet = AccountModel(
        id: 'wallet_trung_02',
        userId: 1,
        name: 'Ví cập nhật Offline',
        type: AccountType.cash,
        balance: 300.0,
        icon: Icons.wallet,
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 5),
      );
      localDataSource.accountsDb.add(newLocalWallet);

      final oldRemoteWallet = AccountModel(
        id: 'wallet_trung_02',
        userId: 1,
        name: 'Ví cũ trên Cloud',
        type: AccountType.cash,
        balance: 150.0,
        icon: Icons.wallet,
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );
      remoteDataSource.firestoreDb.add(oldRemoteWallet);

      await repository.syncWithFirebase(1, 'remote_user_uid');

      expect(remoteDataSource.firestoreDb.first.name, 'Ví cập nhật Offline');
      expect(remoteDataSource.firestoreDb.first.balance, 300.0);
    });
  });

  group('WalletRepositoryImpl Existence Checks and Wallet Data Tests', () {
    setUp(() {
      localDataSource.accountsDb.clear();
      localDataSource.goalsDb.clear();
      localDataSource.categoriesDb.clear();
    });

    test('hasWalletData() trả về false khi không có bất kỳ dữ liệu nào', () async {
      final result = await repository.hasWalletData(1);
      expect(result, isFalse);
    });

    test('hasWalletData() trả về true khi chỉ có accounts hoạt động', () async {
      localDataSource.accountsDb.add(AccountModel(
        id: 'acc_1',
        userId: 1,
        name: 'Main Cash',
        type: AccountType.cash,
        balance: 100.0,
        icon: Icons.wallet,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));

      expect(await repository.hasWalletData(1), isTrue);
    });

    test('hasWalletData() trả về false khi tài khoản duy nhất bị soft delete', () async {
      localDataSource.accountsDb.add(AccountModel(
        id: 'acc_1',
        userId: 1,
        name: 'Deleted Cash',
        type: AccountType.cash,
        balance: 100.0,
        icon: Icons.wallet,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        deletedAt: DateTime.now(),
      ));

      expect(await repository.hasWalletData(1), isFalse);
    });

    test('hasWalletData() trả về true khi có savings goals', () async {
      localDataSource.goalsDb.add(SavingGoalModel(
        id: 'goal_1',
        name: 'New Car',
        currentAmount: 10.0,
        targetAmount: 100.0,
        estimatedDate: DateTime.now(),
        icon: Icons.car_rental,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));

      expect(await repository.hasWalletData(1), isTrue);
    });

    test('hasWalletData() trả về true khi có budget categories', () async {
      localDataSource.categoriesDb.add(BudgetCategoryModel(
        id: 'cat_1',
        name: 'Food',
        spent: 50.0,
        budget: 500.0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));

      expect(await repository.hasWalletData(1), isTrue);
    });
  });
}

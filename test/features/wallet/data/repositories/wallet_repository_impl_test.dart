import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:spend_io_app/features/wallet/data/datasource/wallet_local_data_source.dart';
import 'package:spend_io_app/features/wallet/data/datasource/wallet_remote_data_source.dart';
import 'package:spend_io_app/features/wallet/data/models/account_model.dart';
import 'package:spend_io_app/features/wallet/data/models/saving_goal_model.dart';
import 'package:spend_io_app/features/wallet/data/repositories/wallet_repository_impl.dart';
import 'package:spend_io_app/features/wallet/domain/entities/account_entity.dart';
import 'package:spend_io_app/features/wallet/domain/entities/budget_category_entity.dart';

// --------------------------------------------------------------------
// LỚP MOCK ĐỂ KIỂM THỬ KHÔNG PHỤ THUỘC VÀO SQLITE & FIRESTORE THẬT
// --------------------------------------------------------------------

class FakeLocalDataSource implements WalletLocalDataSource {
  final List<AccountModel> accountsDb = [];
  final List<SavingGoalModel> goalsDb = [];

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
  List<BudgetCategoryEntity> getCategories() => [];
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
      // Gán dữ liệu local tạo offline
      final offlineWallet = AccountModel(
        id: 'wallet_local_01',
        name: 'Offline Cash',
        type: AccountType.cash,
        balance: 100.0,
        icon: Icons.wallet,
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );
      localDataSource.accountsDb.add(offlineWallet);

      // Thực thi đồng bộ
      await repository.syncWithFirebase(1, 'remote_user_uid');

      // Xác minh remote đã nhận được ví từ local đẩy lên
      expect(remoteDataSource.firestoreDb.length, 1);
      expect(remoteDataSource.firestoreDb.first.id, 'wallet_local_01');
      expect(remoteDataSource.firestoreDb.first.name, 'Offline Cash');
    });

    test('Nên tải ví từ remote xuống local nếu chỉ tồn tại ở Remote', () async {
      // Gán dữ liệu remote
      final remoteWallet = AccountModel(
        id: 'wallet_remote_01',
        name: 'Cloud Wallet',
        type: AccountType.bank,
        balance: 5000.0,
        icon: Icons.account_balance,
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );
      remoteDataSource.firestoreDb.add(remoteWallet);

      // Thực thi đồng bộ
      await repository.syncWithFirebase(1, 'remote_user_uid');

      // Xác minh local đã lưu được ví tải xuống
      expect(localDataSource.accountsDb.length, 1);
      expect(localDataSource.accountsDb.first.id, 'wallet_remote_01');
      expect(localDataSource.accountsDb.first.name, 'Cloud Wallet');
    });

    test('Nên cập nhật Local nếu Remote có updatedAt mới hơn', () async {
      final oldLocalWallet = AccountModel(
        id: 'wallet_trung_01',
        name: 'Tài khoản gốc',
        type: AccountType.eWallet,
        balance: 200.0,
        icon: Icons.wallet,
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1), // Cũ hơn
      );
      localDataSource.accountsDb.add(oldLocalWallet);

      final newRemoteWallet = AccountModel(
        id: 'wallet_trung_01',
        name: 'Tài khoản cập nhật trên Web',
        type: AccountType.eWallet,
        balance: 250.0, // Đã thay đổi số dư
        icon: Icons.wallet,
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 2), // Mới hơn
      );
      remoteDataSource.firestoreDb.add(newRemoteWallet);

      await repository.syncWithFirebase(1, 'remote_user_uid');

      // Kiểm tra local được cập nhật theo remote
      expect(localDataSource.accountsDb.first.name, 'Tài khoản cập nhật trên Web');
      expect(localDataSource.accountsDb.first.balance, 250.0);
    });

    test('Nên cập nhật Remote nếu Local có updatedAt mới hơn', () async {
      final newLocalWallet = AccountModel(
        id: 'wallet_trung_02',
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
        name: 'Ví cũ trên Cloud',
        type: AccountType.cash,
        balance: 150.0,
        icon: Icons.wallet,
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1), 
      );
      remoteDataSource.firestoreDb.add(oldRemoteWallet);

      await repository.syncWithFirebase(1, 'remote_user_uid');

      // Kiểm tra remote được cập nhật theo local
      expect(remoteDataSource.firestoreDb.first.name, 'Ví cập nhật Offline');
      expect(remoteDataSource.firestoreDb.first.balance, 300.0);
    });
  });
}

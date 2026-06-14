import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:spend_io_app/features/account/data/datasource/account_local_data_source.dart';
import 'package:spend_io_app/features/account/data/datasource/account_remote_data_source.dart';
import 'package:spend_io_app/features/account/data/models/account_model.dart';
import 'package:spend_io_app/features/account/data/repositories/account_repository_impl.dart';
import 'package:spend_io_app/features/account/domain/entities/account_entity.dart';

class FakeAccountLocalDataSource implements AccountLocalDataSource {
  final List<AccountModel> accountsDb = [];

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
  Future<bool> hasAccounts(int userId) async {
    return accountsDb.where((a) => a.userId == userId && a.deletedAt == null).isNotEmpty;
  }
}

class FakeAccountRemoteDataSource implements AccountRemoteDataSource {
  final List<AccountModel> firestoreDb = [];

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
}

void main() {
  late FakeAccountLocalDataSource localDataSource;
  late FakeAccountRemoteDataSource remoteDataSource;
  late AccountRepositoryImpl repository;

  setUp(() {
    localDataSource = FakeAccountLocalDataSource();
    remoteDataSource = FakeAccountRemoteDataSource();
    repository = AccountRepositoryImpl(
      localDataSource: localDataSource,
      remoteDataSource: remoteDataSource,
    );
  });

  group('AccountRepositoryImpl CRUD & Soft Delete Tests', () {
    test('createAccount() nên chèn SQLite và đẩy lên remote', () async {
      final account = AccountEntity(
        id: 'new_acc_01',
        userId: 1,
        name: 'New Account',
        type: AccountType.savingsAccount,
        balance: 1000.0,
        icon: Icons.wallet,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await repository.createAccount(1, 'remote_user_uid', account);

      expect(localDataSource.accountsDb.length, 1);
      expect(localDataSource.accountsDb.first.id, 'new_acc_01');
      expect(localDataSource.accountsDb.first.type, AccountType.savingsAccount);

      expect(remoteDataSource.firestoreDb.length, 1);
      expect(remoteDataSource.firestoreDb.first.id, 'new_acc_01');
    });

    test('updateAccount() nên cập nhật SQLite và đẩy lên remote', () async {
      final account = AccountEntity(
        id: 'acc_01',
        userId: 1,
        name: 'Updated Name',
        type: AccountType.cash,
        balance: 1500.0,
        icon: Icons.wallet,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      localDataSource.accountsDb.add(AccountModel.fromEntity(account));

      final updatedAccount = AccountEntity(
        id: 'acc_01',
        userId: 1,
        name: 'Updated Name 2',
        type: AccountType.cash,
        balance: 1800.0,
        icon: Icons.wallet,
        createdAt: account.createdAt,
        updatedAt: DateTime.now(),
      );

      await repository.updateAccount(1, 'remote_user_uid', updatedAccount);

      expect(localDataSource.accountsDb.first.name, 'Updated Name 2');
      expect(localDataSource.accountsDb.first.balance, 1800.0);
      expect(remoteDataSource.firestoreDb.first.name, 'Updated Name 2');
    });

    test('deleteAccount() nên đặt deletedAt và ẩn khỏi danh sách UI', () async {
      final activeWallet = AccountModel(
        id: 'wallet_to_delete',
        userId: 1,
        name: 'To Delete',
        type: AccountType.cash,
        balance: 200.0,
        icon: Icons.wallet,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      localDataSource.accountsDb.clear();
      remoteDataSource.firestoreDb.clear();
      localDataSource.accountsDb.add(activeWallet);

      var accounts = await repository.getAccounts(1, 'remote_user_uid');
      expect(accounts.length, 1);

      await repository.deleteAccount(1, 'remote_user_uid', 'wallet_to_delete');

      expect(localDataSource.accountsDb.length, 1);
      expect(localDataSource.accountsDb.first.deletedAt, isNotNull);

      accounts = await repository.getAccounts(1, 'remote_user_uid');
      expect(accounts.length, 0);

      expect(remoteDataSource.firestoreDb.length, 1);
      expect(remoteDataSource.firestoreDb.first.deletedAt, isNotNull);
    });

    test('restoreAccount() nên xóa deletedAt và hiển thị lại trên UI', () async {
      final now = DateTime.now();
      final deletedWallet = AccountModel(
        id: 'wallet_to_restore',
        userId: 1,
        name: 'To Restore',
        type: AccountType.cash,
        balance: 200.0,
        icon: Icons.wallet,
        createdAt: now,
        updatedAt: now,
        deletedAt: now,
      );
      localDataSource.accountsDb.clear();
      remoteDataSource.firestoreDb.clear();
      localDataSource.accountsDb.add(deletedWallet);

      var accounts = await repository.getAccounts(1, 'remote_user_uid');
      expect(accounts.length, 0);

      await repository.restoreAccount(1, 'remote_user_uid', 'wallet_to_restore');

      expect(localDataSource.accountsDb.first.deletedAt, isNull);
      accounts = await repository.getAccounts(1, 'remote_user_uid');
      expect(accounts.length, 1);

      expect(remoteDataSource.firestoreDb.first.deletedAt, isNull);
    });
  });
}

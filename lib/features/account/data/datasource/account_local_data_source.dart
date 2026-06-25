import 'package:spend_io_app/core/database/app_database.dart';
import 'package:spend_io_app/features/account/data/models/account_model.dart';
import 'package:sqflite/sqflite.dart';

abstract class AccountLocalDataSource {
  Future<List<AccountModel>> getAccounts(int userId);
  Future<void> saveAccount(int userId, AccountModel account);
  Future<void> createAccount(int userId, AccountModel account);
  Future<void> updateAccount(int userId, AccountModel account);
  Future<void> deleteAccount(String accountId);
  Future<void> softDeleteAccount(String accountId);
  Future<void> restoreAccount(String accountId);
  Future<bool> hasAccounts(int userId);
}

class AccountLocalDataSourceImpl implements AccountLocalDataSource {
  Future<Database> get _db async => await AppDatabase.database;

  @override
  Future<List<AccountModel>> getAccounts(int userId) async {
    final db = await _db;
    final result = await db.query(
      'wallets',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );
    return result.map((map) => AccountModel.fromMap(map)).toList();
  }

  @override
  Future<void> saveAccount(int userId, AccountModel account) async {
    final db = await _db;
    final map = account.toMap();
    map['user_id'] = userId;
    await db.insert(
      'wallets',
      map,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> createAccount(int userId, AccountModel account) async {
    final db = await _db;
    final map = account.toMap();
    map['user_id'] = userId;
    await db.insert(
      'wallets',
      map,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> updateAccount(int userId, AccountModel account) async {
    final db = await _db;
    final map = account.toMap();
    map['user_id'] = userId;
    await db.update(
      'wallets',
      map,
      where: 'id = ? AND user_id = ?',
      whereArgs: [account.id, userId],
    );
  }

  @override
  Future<void> deleteAccount(String accountId) async {
    final db = await _db;
    await db.delete(
      'wallets',
      where: 'id = ?',
      whereArgs: [accountId],
    );
  }

  @override
  Future<void> softDeleteAccount(String accountId) async {
    final db = await _db;
    final nowStr = DateTime.now().toIso8601String();
    await db.update(
      'wallets',
      {
        'deleted_at': nowStr,
        'updated_at': nowStr,
      },
      where: 'id = ?',
      whereArgs: [accountId],
    );
  }

  @override
  Future<void> restoreAccount(String accountId) async {
    final db = await _db;
    final nowStr = DateTime.now().toIso8601String();
    await db.update(
      'wallets',
      {
        'deleted_at': null,
        'updated_at': nowStr,
      },
      where: 'id = ?',
      whereArgs: [accountId],
    );
  }

  @override
  Future<bool> hasAccounts(int userId) async {
    final db = await _db;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM wallets WHERE user_id = ? AND deleted_at IS NULL',
      [userId],
    );
    final count = Sqflite.firstIntValue(result) ?? 0;
    return count > 0;
  }
}

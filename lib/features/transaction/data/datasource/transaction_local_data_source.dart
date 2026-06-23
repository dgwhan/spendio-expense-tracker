import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:spend_io_app/core/database/app_database.dart';
import 'package:spend_io_app/core/database/tables/transactions_table.dart';
import '../models/transaction_model.dart';

abstract class TransactionLocalDataSource {
  Future<List<TransactionModel>> getAll();
  Future<List<TransactionModel>> getByAccountId(String accountId);
  Future<void> insert(TransactionModel model);
  Future<void> update(TransactionModel model);
  Future<void> delete(String id);

  Future<List<TransactionModel>> getTransactionsInPeriod({
    required int userId,
    required String startDateIso,
    required String endDateIso,
  });

  Future<Map<String, double>> getSpentGroupByCategory({
    required int userId,
    required String startDateIso,
    required String endDateIso,
  });

  Future<double> getTotalSpentInPeriod({
    required int userId,
    required String startDateIso,
    required String endDateIso,
  });

  Future<double> getTotalSpentByCategory({
    required int userId,
    required String categoryId,
    required String startDateIso,
    required String endDateIso,
  });
}

class TransactionLocalDataSourceImpl implements TransactionLocalDataSource {
  TransactionLocalDataSourceImpl();

  Future<Database> get _db async => await AppDatabase.database;

  @override
  Future<List<TransactionModel>> getAll() async {
    final db = await _db;
    final result = await db.query(
      TransactionsTable.tableName,
      orderBy: 'transaction_date DESC, created_at DESC',
    );
    return result.map(TransactionModel.fromMap).toList();
  }

  @override
  Future<List<TransactionModel>> getByAccountId(String accountId) async {
    final db = await _db;
    final result = await db.query(
      TransactionsTable.tableName,
      where: 'account_id = ?',
      whereArgs: [accountId],
      orderBy: 'transaction_date DESC, created_at DESC',
    );
    return result.map(TransactionModel.fromMap).toList();
  }

  @override
  Future<void> insert(TransactionModel model) async {
    final db = await _db;

    final users =
        await db.query('users', where: 'id = ?', whereArgs: [model.userId]);
    final wallets = await db
        .query('wallets', where: 'id = ?', whereArgs: [model.accountId]);
    final cats = await db
        .query('categories', where: 'id = ?', whereArgs: [model.categoryId]);

    debugPrint(
        '[FK Check] user found: ${users.isNotEmpty} (id: ${model.userId})');
    debugPrint(
        '[FK Check] wallet found: ${wallets.isNotEmpty} (id: ${model.accountId})');
    debugPrint(
        '[FK Check] category found: ${cats.isNotEmpty} (id: ${model.categoryId})');

    await db.insert(
      TransactionsTable.tableName,
      model.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> update(TransactionModel model) async {
    final db = await _db;
    await db.update(
      TransactionsTable.tableName,
      model.toMap(),
      where: 'id = ?',
      whereArgs: [model.id],
    );
  }

  @override
  Future<void> delete(String id) async {
    final db = await _db;
    await db.delete(
      TransactionsTable.tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<List<TransactionModel>> getTransactionsInPeriod({
    required int userId,
    required String startDateIso,
    required String endDateIso,
  }) async {
    final db = await _db;
    final List<Map<String, dynamic>> result = await db.query(
      TransactionsTable.tableName,
      where: 'user_id = ? AND datetime(transaction_date) >= datetime(?) AND datetime(transaction_date) <= datetime(?)',
      whereArgs: [userId, startDateIso, endDateIso],
      orderBy: 'transaction_date DESC, created_at DESC',
    );
    return result.map(TransactionModel.fromMap).toList();
  }

  // So sanh thoi gian qua ham datetime() cua SQLite thay vi so sanh chuoi
  // ASCII thuan. datetime() chuan hoa duoc ca hai dang co va khong co ky tu
  // 'T', tranh viec lech ket qua khi du lieu cu trong DB con sai format.
  static const String _periodWhereClause = 'user_id = ? AND type = ? '
      'AND datetime(transaction_date) >= datetime(?) '
      'AND datetime(transaction_date) <= datetime(?)';

  static const String _periodWithCategoryWhereClause =
      'user_id = ? AND category_id = ? AND type = ? '
      'AND datetime(transaction_date) >= datetime(?) '
      'AND datetime(transaction_date) <= datetime(?)';

  @override
  Future<Map<String, double>> getSpentGroupByCategory({
    required int userId,
    required String startDateIso,
    required String endDateIso,
  }) async {
    final db = await _db;

    final List<Map<String, dynamic>> result = await db.query(
      TransactionsTable.tableName,
      columns: ['category_id', 'SUM(amount) AS total_amount'],
      where: _periodWhereClause,
      whereArgs: [userId, 'expense', startDateIso, endDateIso],
      groupBy: 'category_id',
    );

    debugPrint(
        '[BUDGET SYNC] getSpentGroupByCategory range=$startDateIso..$endDateIso rows=${result.length}');

    final Map<String, double> spentMap = {};
    for (var row in result) {
      final String? categoryId = row['category_id'] as String?;
      final num? totalAmount = row['total_amount'] as num?;
      if (categoryId != null && totalAmount != null) {
        spentMap[categoryId] = totalAmount.toDouble();
      }
    }
    return spentMap;
  }

  @override
  Future<double> getTotalSpentInPeriod({
    required int userId,
    required String startDateIso,
    required String endDateIso,
  }) async {
    final db = await _db;

    final List<Map<String, dynamic>> result = await db.query(
      TransactionsTable.tableName,
      columns: ['SUM(amount) AS total_amount'],
      where: _periodWhereClause,
      whereArgs: [userId, 'expense', startDateIso, endDateIso],
    );

    debugPrint(
        '[BUDGET SYNC] getTotalSpentInPeriod range=$startDateIso..$endDateIso total=${result.isNotEmpty ? result.first['total_amount'] : 0}');

    if (result.isEmpty || result.first['total_amount'] == null) return 0.0;
    return (result.first['total_amount'] as num).toDouble();
  }

  @override
  Future<double> getTotalSpentByCategory({
    required int userId,
    required String categoryId,
    required String startDateIso,
    required String endDateIso,
  }) async {
    final db = await _db;

    final List<Map<String, dynamic>> result = await db.query(
      TransactionsTable.tableName,
      columns: ['SUM(amount) AS total_amount'],
      where: _periodWithCategoryWhereClause,
      whereArgs: [userId, categoryId, 'expense', startDateIso, endDateIso],
    );

    if (result.isEmpty || result.first['total_amount'] == null) return 0.0;
    return (result.first['total_amount'] as num).toDouble();
  }
}

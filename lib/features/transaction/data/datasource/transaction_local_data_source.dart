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

  // 🔴 INTERFACE: Khai báo 2 hàm mới cho Budget tính toán
  Future<Map<String, double>> getSpentGroupByCategory({
    required String startDateIso,
    required String endDateIso,
  });

  Future<double> getTotalSpentInPeriod({
    required int userId,
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

  // 🔴 IMPLEMENTATION 1: Query gom nhóm Group By chuẩn style _db của dự án
  @override
  Future<Map<String, double>> getSpentGroupByCategory({
    required String startDateIso,
    required String endDateIso,
  }) async {
    final db = await _db; // Await getter của dự án bạn

    final List<Map<String, dynamic>> result = await db.query(
      TransactionsTable.tableName,
      columns: ['category_id', 'SUM(amount) AS total_amount'],
      where: 'created_at >= ? AND created_at <= ?',
      whereArgs: [startDateIso, endDateIso],
      groupBy: 'category_id',
    );

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
      where: 'user_id = ? AND created_at >= ? AND created_at <= ?',
      whereArgs: [userId, startDateIso, endDateIso],
    );

    if (result.isEmpty || result.first['total_amount'] == null) return 0.0;
    return (result.first['total_amount'] as num).toDouble();
  }
}

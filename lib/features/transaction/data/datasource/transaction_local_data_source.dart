import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:spend_io_app/core/database/app_database.dart'; // Đảm bảo import file này
import 'package:spend_io_app/core/database/tables/transactions_table.dart';
import '../models/transaction_model.dart';

abstract class TransactionLocalDataSource {
  Future<List<TransactionModel>> getByAccountId(String accountId);
  Future<void> insert(TransactionModel model);
  Future<void> update(TransactionModel model);
  Future<void> delete(String id);
}

class TransactionLocalDataSourceImpl implements TransactionLocalDataSource {
  // 1. Constructor rỗng - KHÔNG yêu cầu truyền 'db' từ ngoài vào nữa
  TransactionLocalDataSourceImpl();

  // 2. Tự động await lấy instance Database thực tế khi có hàm gọi đến
  Future<Database> get _db async => await AppDatabase.database;

  @override
  Future<List<TransactionModel>> getByAccountId(String accountId) async {
    final db = await _db; // Await lấy db tại đây
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
}

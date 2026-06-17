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
}

import 'package:sqflite/sqflite.dart';
import '../../../../core/database/app_database.dart';
import '../models/account_model.dart';
import '../models/saving_goal_model.dart';
import '../models/budget_category_model.dart';

abstract class WalletLocalDataSource {
  Future<List<AccountModel>> getAccounts(int userId);
  Future<void> saveAccount(int userId, AccountModel account);
  Future<void> deleteAccount(String accountId);

  // New CRUD contracts
  Future<void> createAccount(int userId, AccountModel account);
  Future<void> updateAccount(int userId, AccountModel account);
  Future<void> softDeleteAccount(String accountId);
  Future<void> restoreAccount(String accountId);

  Future<List<SavingGoalModel>> getGoals(int userId);
  Future<void> saveGoal(int userId, SavingGoalModel goal);
  Future<void> deleteGoal(String goalId);

  Future<List<BudgetCategoryModel>> getCategories(int userId);
  Future<void> insertCategory(int userId, BudgetCategoryModel category);
  Future<void> updateCategory(int userId, BudgetCategoryModel category);

  Future<bool> hasAccounts(int userId);
  Future<bool> hasGoals(int userId);
  Future<bool> hasCategories(int userId);
}

class WalletLocalDataSourceImpl implements WalletLocalDataSource {
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
  Future<void> deleteAccount(String accountId) async {
    final db = await _db;
    await db.delete(
      'wallets',
      where: 'id = ?',
      whereArgs: [accountId],
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
  Future<List<SavingGoalModel>> getGoals(int userId) async {
    final db = await _db;
    final result = await db.query(
      'financial_goals',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );
    return result.map((map) => SavingGoalModel.fromMap(map)).toList();
  }

  @override
  Future<void> saveGoal(int userId, SavingGoalModel goal) async {
    final db = await _db;
    final map = goal.toMap();
    map['user_id'] = userId;
    await db.insert(
      'financial_goals',
      map,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> deleteGoal(String goalId) async {
    final db = await _db;
    await db.delete(
      'financial_goals',
      where: 'id = ?',
      whereArgs: [goalId],
    );
  }

  @override
  Future<List<BudgetCategoryModel>> getCategories(int userId) async {
    final db = await _db;
    final result = await db.query(
      'budget_categories',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at ASC',
    );
    return result.map((map) => BudgetCategoryModel.fromMap(map)).toList();
  }

  @override
  Future<void> insertCategory(int userId, BudgetCategoryModel category) async {
    final db = await _db;
    final map = category.toMap();
    map['user_id'] = userId;
    await db.insert(
      'budget_categories',
      map,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> updateCategory(int userId, BudgetCategoryModel category) async {
    final db = await _db;
    final map = category.toMap();
    map['user_id'] = userId;
    await db.update(
      'budget_categories',
      map,
      where: 'id = ? AND user_id = ?',
      whereArgs: [category.id, userId],
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

  @override
  Future<bool> hasGoals(int userId) async {
    final db = await _db;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM financial_goals WHERE user_id = ?',
      [userId],
    );
    final count = Sqflite.firstIntValue(result) ?? 0;
    return count > 0;
  }

  @override
  Future<bool> hasCategories(int userId) async {
    final db = await _db;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM budget_categories WHERE user_id = ?',
      [userId],
    );
    final count = Sqflite.firstIntValue(result) ?? 0;
    return count > 0;
  }
}

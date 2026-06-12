import 'package:sqflite/sqflite.dart';
import '../../../../core/database/app_database.dart';
import '../../domain/entities/budget_category_entity.dart';
import '../models/account_model.dart';
import '../models/saving_goal_model.dart';

abstract class WalletLocalDataSource {
  Future<List<AccountModel>> getAccounts(int userId);
  Future<void> saveAccount(int userId, AccountModel account);
  Future<void> deleteAccount(String accountId);

  Future<List<SavingGoalModel>> getGoals(int userId);
  Future<void> saveGoal(int userId, SavingGoalModel goal);
  Future<void> deleteGoal(String goalId);

  List<BudgetCategoryEntity> getCategories();
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
  List<BudgetCategoryEntity> getCategories() {
    return [];
  }
}

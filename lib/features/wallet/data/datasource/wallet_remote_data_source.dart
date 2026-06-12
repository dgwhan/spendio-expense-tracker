import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/account_model.dart';
import '../models/saving_goal_model.dart';

abstract class WalletRemoteDataSource {
  Future<List<AccountModel>> getAccounts(String userId);
  Future<void> saveAccount(String userId, AccountModel account);
  Future<void> deleteAccount(String userId, String accountId);

  Future<List<SavingGoalModel>> getGoals(String userId);
  Future<void> saveGoal(String userId, SavingGoalModel goal);
  Future<void> deleteGoal(String userId, String goalId);
}

class WalletRemoteDataSourceImpl implements WalletRemoteDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<List<AccountModel>> getAccounts(String userId) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('wallets')
        .get();
    return snapshot.docs.map((doc) => AccountModel.fromMap(doc.data())).toList();
  }

  @override
  Future<void> saveAccount(String userId, AccountModel account) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('wallets')
        .doc(account.id)
        .set(account.toMap());
  }

  @override
  Future<void> deleteAccount(String userId, String accountId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('wallets')
        .doc(accountId)
        .delete();
  }

  @override
  Future<List<SavingGoalModel>> getGoals(String userId) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('goals')
        .get();
    return snapshot.docs.map((doc) => SavingGoalModel.fromMap(doc.data())).toList();
  }

  @override
  Future<void> saveGoal(String userId, SavingGoalModel goal) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('goals')
        .doc(goal.id)
        .set(goal.toMap());
  }

  @override
  Future<void> deleteGoal(String userId, String goalId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('goals')
        .doc(goalId)
        .delete();
  }
}

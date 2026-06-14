import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/account_model.dart';

abstract class AccountRemoteDataSource {
  Future<List<AccountModel>> getAccounts(String userId);
  Future<void> saveAccount(String userId, AccountModel account);
  Future<void> deleteAccount(String userId, String accountId);
}

class AccountRemoteDataSourceImpl implements AccountRemoteDataSource {
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
}

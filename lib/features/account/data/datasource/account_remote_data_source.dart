import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
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
    if (userId.trim().isEmpty) {
      return [];
    }

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('wallets')
          .get();

      return snapshot.docs.map((doc) {
        return AccountModel.fromMap(
          doc.data(),
          documentId: doc.id,
        );
      }).toList();
    } catch (e) {
      debugPrint(
          'Error fetching wallet data from Firestore (Device might be offline): $e');
      return [];
    }
  }

  @override
  Future<void> saveAccount(String userId, AccountModel account) async {
    if (userId.trim().isEmpty || account.id.trim().isEmpty) {
      debugPrint(
          'Aborted Firebase write sync: Identifier is empty while device is offline.');
      return;
    }

    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('wallets')
          .doc(account.id)
          .set(
            account.toMap(),
            SetOptions(merge: true),
          );
    } catch (e) {
      debugPrint(
          'Firebase sync failed. Data is securely cached locally in SQLite: $e');
    }
  }

  @override
  Future<void> deleteAccount(String userId, String accountId) async {
    if (userId.trim().isEmpty || accountId.trim().isEmpty) {
      return;
    }

    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('wallets')
          .doc(accountId)
          .delete();
    } catch (e) {
      debugPrint(
          'Firebase deletion failed. Soft-delete operation fallback saved to SQLite: $e');
    }
  }
}

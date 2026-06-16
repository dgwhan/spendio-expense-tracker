import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:spend_io_app/features/transaction/data/models/transaction_model.dart';

abstract class TransactionRemoteDataSource {
  Future<void> saveTransaction(String uid, TransactionModel model);
  Future<void> removeTransaction(String uid, String id);
  Future<List<TransactionModel>> getTransactions(String uid);
}

class TransactionRemoteDataSourceImpl implements TransactionRemoteDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Path: users/{uid}/transactions/{transactionId}
  CollectionReference<Map<String, dynamic>> _collection(String uid) =>
      _firestore.collection('users').doc(uid).collection('transactions');

  @override
  Future<void> saveTransaction(String uid, TransactionModel model) async {
    try {
      await _collection(uid).doc(model.id).set(model.toMap());
      debugPrint('[TransactionRemote] Saved transaction: ${model.id}');
    } on FirebaseException catch (e) {
      debugPrint(
          '[TransactionRemote] saveTransaction failed — code: ${e.code}, '
          'message: ${e.message}. Continuing in offline mode.');
    } catch (e) {
      debugPrint('[TransactionRemote] saveTransaction unexpected error: $e. '
          'Continuing in offline mode.');
    }
  }

  @override
  Future<void> removeTransaction(String uid, String id) async {
    try {
      await _collection(uid).doc(id).delete();
      debugPrint('[TransactionRemote] Removed transaction: $id');
    } on FirebaseException catch (e) {
      debugPrint(
          '[TransactionRemote] removeTransaction failed — code: ${e.code}, '
          'message: ${e.message}. Continuing in offline mode.');
    } catch (e) {
      debugPrint('[TransactionRemote] removeTransaction unexpected error: $e. '
          'Continuing in offline mode.');
    }
  }

  @override
  Future<List<TransactionModel>> getTransactions(String uid) async {
    try {
      final snapshot = await _collection(uid).get();
      final results = snapshot.docs
          .map((doc) => TransactionModel.fromMap(doc.data()))
          .toList();
      debugPrint(
          '[TransactionRemote] Fetched ${results.length} transactions for uid: $uid');
      return results;
    } on FirebaseException catch (e) {
      debugPrint(
          '[TransactionRemote] getTransactions failed — code: ${e.code}, '
          'message: ${e.message}. Returning empty list.');
      return [];
    } catch (e) {
      debugPrint('[TransactionRemote] getTransactions unexpected error: $e. '
          'Returning empty list.');
      return [];
    }
  }
}

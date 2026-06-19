import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:spend_io_app/features/budget/data/models/budget_model.dart';
import 'package:spend_io_app/features/budget/data/models/budget_category_model.dart';

abstract class BudgetRemoteDataSource {
  Future<void> syncBudget(BudgetModel budget);
  Future<void> deleteBudget(String budgetId, int userId);
  Future<void> syncBudgetCategory(BudgetCategoryModel category);
  Future<void> deleteBudgetCategory(String id, int userId);
  Future<List<BudgetModel>> fetchBudgetsFromServer(int userId);
  Future<List<BudgetCategoryModel>> fetchBudgetCategoriesFromServer(int userId);
}

class BudgetRemoteDataSourceImpl implements BudgetRemoteDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  BudgetRemoteDataSourceImpl({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  String? _getCurrentUserUid() {
    return _auth.currentUser?.uid;
  }

  @override
  Future<void> syncBudget(BudgetModel budget) async {
    try {
      final uid = _getCurrentUserUid();
      if (uid == null) {
        debugPrint(
            '[BUDGET_REMOTE_DATA_SOURCE] Sync aborted: User is not authenticated.');
        return;
      }

      await _firestore
          .collection('users')
          .doc(uid)
          .collection('budgets')
          .doc(budget.id)
          .set(budget.toMap(), SetOptions(merge: true));

      debugPrint(
          '[BUDGET_REMOTE_DATA_SOURCE] Sync budget success. Path: users/$uid/budgets/${budget.id}');
    } catch (e) {
      debugPrint('[BUDGET_REMOTE_DATA_SOURCE] Sync budget error: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteBudget(String budgetId, int userId) async {
    try {
      final uid = _getCurrentUserUid();
      if (uid == null) {
        debugPrint(
            '[BUDGET_REMOTE_DATA_SOURCE] Delete aborted: User is not authenticated.');
        return;
      }

      await _firestore
          .collection('users')
          .doc(uid)
          .collection('budgets')
          .doc(budgetId)
          .delete();

      debugPrint(
          '[BUDGET_REMOTE_DATA_SOURCE] Delete budget success. Path: users/$uid/budgets/$budgetId');
    } catch (e) {
      debugPrint('[BUDGET_REMOTE_DATA_SOURCE] Delete budget error: $e');
      rethrow;
    }
  }

  @override
  Future<void> syncBudgetCategory(BudgetCategoryModel category) async {
    try {
      final uid = _getCurrentUserUid();
      if (uid == null) {
        debugPrint(
            '[BUDGET_REMOTE_DATA_SOURCE] Sync category aborted: User is not authenticated.');
        return;
      }

      await _firestore
          .collection('users')
          .doc(uid)
          .collection('budget_categories')
          .doc(category.id)
          .set(category.toMap(), SetOptions(merge: true));

      debugPrint(
          '[BUDGET_REMOTE_DATA_SOURCE] Sync budget category success. Path: users/$uid/budget_categories/${category.id}');
    } catch (e) {
      debugPrint('[BUDGET_REMOTE_DATA_SOURCE] Sync budget category error: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteBudgetCategory(String id, int userId) async {
    try {
      final uid = _getCurrentUserUid();
      if (uid == null) {
        debugPrint(
            '[BUDGET_REMOTE_DATA_SOURCE] Delete category aborted: User is not authenticated.');
        return;
      }

      await _firestore
          .collection('users')
          .doc(uid)
          .collection('budget_categories')
          .doc(id)
          .delete();

      debugPrint(
          '[BUDGET_REMOTE_DATA_SOURCE] Delete budget category success. Path: users/$uid/budget_categories/$id');
    } catch (e) {
      debugPrint(
          '[BUDGET_REMOTE_DATA_SOURCE] Delete budget category error: $e');
      rethrow;
    }
  }

  @override
  Future<List<BudgetModel>> fetchBudgetsFromServer(int userId) async {
    try {
      final uid = _getCurrentUserUid();
      if (uid == null) {
        debugPrint(
            '[BUDGET_REMOTE_DATA_SOURCE] Fetch aborted: User is not authenticated.');
        return [];
      }

      final snapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('budgets')
          .orderBy('start_date', descending: true)
          .get();

      debugPrint(
          '[BUDGET_REMOTE_DATA_SOURCE] Fetch budgets success. Count: ${snapshot.docs.length}');
      return snapshot.docs
          .map((doc) => BudgetModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      debugPrint('[BUDGET_REMOTE_DATA_SOURCE] Fetch budgets error: $e');
      return [];
    }
  }

  @override
  Future<List<BudgetCategoryModel>> fetchBudgetCategoriesFromServer(
      int userId) async {
    try {
      final uid = _getCurrentUserUid();
      if (uid == null) {
        debugPrint(
            '[BUDGET_REMOTE_DATA_SOURCE] Fetch categories aborted: User is not authenticated.');
        return [];
      }

      final snapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('budget_categories')
          .orderBy('created_at', descending: true)
          .get();

      debugPrint(
          '[BUDGET_REMOTE_DATA_SOURCE] Fetch budget categories success. Count: ${snapshot.docs.length}');
      return snapshot.docs
          .map((doc) => BudgetCategoryModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      debugPrint(
          '[BUDGET_REMOTE_DATA_SOURCE] Fetch budget categories error: $e');
      return [];
    }
  }
}

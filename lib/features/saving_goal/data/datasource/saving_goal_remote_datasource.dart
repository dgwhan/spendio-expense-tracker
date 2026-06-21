import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/saving_goal_contribution_model.dart';
import '../models/saving_goal_model.dart';

abstract class SavingGoalRemoteDataSource {
  Future<void> syncGoal(SavingGoalModel goal);

  Future<void> deleteGoal(String goalId);

  Future<void> syncContribution(
    GoalContributionModel contribution,
  );

  Future<List<SavingGoalModel>> fetchGoals(
    int userId,
  );

  Future<List<GoalContributionModel>> fetchContributions(
    String goalId,
  );
}

class SavingGoalRemoteDataSourceImpl implements SavingGoalRemoteDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  SavingGoalRemoteDataSourceImpl({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  String? _getCurrentUserUid() {
    return _auth.currentUser?.uid;
  }

  // =========================================================
  // GOALS
  // =========================================================

  @override
  Future<void> syncGoal(
    SavingGoalModel goal,
  ) async {
    try {
      final uid = _getCurrentUserUid();

      if (uid == null) {
        debugPrint(
          '[GOAL_REMOTE] Sync goal aborted. User not authenticated.',
        );
        return;
      }

      await _firestore
          .collection('users')
          .doc(uid)
          .collection('saving_goals')
          .doc(goal.id)
          .set(
            goal.toMap(),
            SetOptions(
              merge: true,
            ),
          );

      debugPrint(
        '[GOAL_REMOTE] Goal synced: ${goal.id}',
      );
    } catch (e) {
      debugPrint(
        '[GOAL_REMOTE] Sync goal error: $e',
      );
      rethrow;
    }
  }

  @override
  Future<void> deleteGoal(
    String goalId,
  ) async {
    try {
      final uid = _getCurrentUserUid();

      if (uid == null) {
        debugPrint(
          '[GOAL_REMOTE] Delete goal aborted. User not authenticated.',
        );
        return;
      }

      await _firestore
          .collection('users')
          .doc(uid)
          .collection('saving_goals')
          .doc(goalId)
          .delete();

      debugPrint(
        '[GOAL_REMOTE] Goal deleted: $goalId',
      );
    } catch (e) {
      debugPrint(
        '[GOAL_REMOTE] Delete goal error: $e',
      );
      rethrow;
    }
  }

  @override
  Future<List<SavingGoalModel>> fetchGoals(
    int userId,
  ) async {
    try {
      final uid = _getCurrentUserUid();

      if (uid == null) {
        debugPrint(
          '[GOAL_REMOTE] Fetch saving_goals aborted. User not authenticated.',
        );
        return [];
      }

      final snapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('saving_goals')
          .orderBy(
            'created_at',
            descending: true,
          )
          .get();

      debugPrint(
        '[GOAL_REMOTE] Fetched ${snapshot.docs.length} saving_goals.',
      );

      return snapshot.docs
          .map(
            (doc) => SavingGoalModel.fromMap(
              doc.data(),
            ),
          )
          .toList();
    } catch (e) {
      debugPrint(
        '[GOAL_REMOTE] Fetch saving_goals error: $e',
      );
      return [];
    }
  }

  // =========================================================
  // CONTRIBUTIONS
  // =========================================================

  @override
  Future<void> syncContribution(
    GoalContributionModel contribution,
  ) async {
    try {
      final uid = _getCurrentUserUid();

      if (uid == null) {
        debugPrint(
          '[GOAL_REMOTE] Sync contribution aborted. User not authenticated.',
        );
        return;
      }

      await _firestore
          .collection('users')
          .doc(uid)
          .collection('saving_goal_contributions')
          .doc(contribution.id)
          .set(
            contribution.toMap(),
            SetOptions(
              merge: true,
            ),
          );

      debugPrint(
        '[GOAL_REMOTE] Contribution synced: ${contribution.id}',
      );
    } catch (e) {
      debugPrint(
        '[GOAL_REMOTE] Sync contribution error: $e',
      );
      rethrow;
    }
  }

  @override
  Future<List<GoalContributionModel>> fetchContributions(
    String goalId,
  ) async {
    try {
      final uid = _getCurrentUserUid();

      if (uid == null) {
        debugPrint(
          '[GOAL_REMOTE] Fetch contributions aborted. User not authenticated.',
        );
        return [];
      }

      final snapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('saving_goal_contributions')
          .where(
            'goal_id',
            isEqualTo: goalId,
          )
          .orderBy(
            'created_at',
            descending: true,
          )
          .get();

      debugPrint(
        '[GOAL_REMOTE] Fetched ${snapshot.docs.length} contributions.',
      );

      return snapshot.docs
          .map(
            (doc) => GoalContributionModel.fromMap(
              doc.data(),
            ),
          )
          .toList();
    } catch (e) {
      debugPrint(
        '[GOAL_REMOTE] Fetch contributions error: $e',
      );
      return [];
    }
  }
}

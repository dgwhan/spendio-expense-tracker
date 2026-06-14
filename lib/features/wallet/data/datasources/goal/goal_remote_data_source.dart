import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/saving_goal_model.dart';

abstract class GoalRemoteDataSource {
  Future<List<SavingGoalModel>> getGoals(String userId);
  Future<void> saveGoal(String userId, SavingGoalModel goal);
  Future<void> deleteGoal(String userId, String goalId);
}

class GoalRemoteDataSourceImpl implements GoalRemoteDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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

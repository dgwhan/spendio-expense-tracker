import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:spend_io_app/features/wallet/data/datasources/goal/goal_local_data_source.dart';
import 'package:spend_io_app/features/wallet/data/datasources/goal/goal_remote_data_source.dart';
import 'package:spend_io_app/features/wallet/data/models/saving_goal_model.dart';
import 'package:spend_io_app/features/wallet/data/repositories/saving_goal_repository_impl.dart';
import 'package:spend_io_app/features/wallet/domain/entities/saving_goal_entity.dart';

class FakeGoalLocalDataSource implements GoalLocalDataSource {
  final List<SavingGoalModel> goalsDb = [];

  @override
  Future<List<SavingGoalModel>> getGoals(int userId) async => goalsDb;

  @override
  Future<void> saveGoal(int userId, SavingGoalModel goal) async {
    goalsDb.removeWhere((g) => g.id == goal.id);
    goalsDb.add(goal);
  }

  @override
  Future<void> deleteGoal(String goalId) async {
    goalsDb.removeWhere((g) => g.id == goalId);
  }

  @override
  Future<bool> hasGoals(int userId) async {
    return goalsDb.isNotEmpty;
  }
}

class FakeGoalRemoteDataSource implements GoalRemoteDataSource {
  final List<SavingGoalModel> firestoreGoalsDb = [];

  @override
  Future<List<SavingGoalModel>> getGoals(String userId) async => firestoreGoalsDb;

  @override
  Future<void> saveGoal(String userId, SavingGoalModel goal) async {
    firestoreGoalsDb.removeWhere((g) => g.id == goal.id);
    firestoreGoalsDb.add(goal);
  }

  @override
  Future<void> deleteGoal(String userId, String goalId) async {
    firestoreGoalsDb.removeWhere((g) => g.id == goalId);
  }
}

void main() {
  late FakeGoalLocalDataSource localDataSource;
  late FakeGoalRemoteDataSource remoteDataSource;
  late SavingGoalRepositoryImpl repository;

  setUp(() {
    localDataSource = FakeGoalLocalDataSource();
    remoteDataSource = FakeGoalRemoteDataSource();
    repository = SavingGoalRepositoryImpl(
      localDataSource: localDataSource,
      remoteDataSource: remoteDataSource,
    );
  });

  group('SavingGoalRepositoryImpl CRUD Tests', () {
    test('saveGoal() nên chèn SQLite và đẩy lên remote', () async {
      final goal = SavingGoalEntity(
        id: 'goal_1',
        name: 'New Car',
        currentAmount: 10.0,
        targetAmount: 100.0,
        estimatedDate: DateTime.now(),
        icon: Icons.car_rental,
      );

      await repository.saveGoal(1, 'remote_user_uid', goal);

      expect(localDataSource.goalsDb.length, 1);
      expect(localDataSource.goalsDb.first.id, 'goal_1');

      expect(remoteDataSource.firestoreGoalsDb.length, 1);
      expect(remoteDataSource.firestoreGoalsDb.first.id, 'goal_1');
    });

    test('deleteGoal() nên xóa SQLite và đẩy lên remote', () async {
      localDataSource.goalsDb.add(SavingGoalModel(
        id: 'goal_to_delete',
        name: 'Delete Me',
        currentAmount: 0.0,
        targetAmount: 100.0,
        estimatedDate: DateTime.now(),
        icon: Icons.car_rental,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));

      await repository.deleteGoal('remote_user_uid', 'goal_to_delete');

      expect(localDataSource.goalsDb.isEmpty, isTrue);
    });
  });
}

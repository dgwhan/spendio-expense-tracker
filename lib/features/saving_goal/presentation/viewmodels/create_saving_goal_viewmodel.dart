import 'package:flutter/foundation.dart';
import 'package:spend_io_app/features/saving_goal/domain/entities/saving_goal_entity.dart';
import 'package:spend_io_app/features/saving_goal/domain/usecases/create_goal_usecase.dart';
import 'package:spend_io_app/features/saving_goal/domain/usecases/delete_goal_usecase.dart';
import 'package:spend_io_app/features/saving_goal/domain/usecases/update_goal_usecase.dart';

class CreateSavingGoalViewModel extends ChangeNotifier {
  final CreateGoalUseCase createGoalUseCase;

  final UpdateGoalUseCase updateGoalUseCase;

  final DeleteGoalUseCase deleteGoalUseCase;

  CreateSavingGoalViewModel({
    required this.createGoalUseCase,
    required this.updateGoalUseCase,
    required this.deleteGoalUseCase,
  });

  bool _loading = false;

  bool get loading => _loading;

  Future<void> createGoal({
    required SavingGoalEntity goal,
  }) async {
    _loading = true;
    notifyListeners();

    try {
      await createGoalUseCase(goal);

      if (kDebugMode) {
        debugPrint('[SavingGoal] CREATE SUCCESS');
        debugPrint(goal.toString());
      }
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('[SavingGoal] CREATE FAILED: $e');
        debugPrintStack(stackTrace: st);
      }
      rethrow;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> updateGoal({
    required SavingGoalEntity goal,
  }) async {
    _loading = true;
    notifyListeners();

    try {
      await updateGoalUseCase(
        goal,
      );
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> deleteGoal({
    required String goalId,
    required int userId,
  }) async {
    _loading = true;
    notifyListeners();

    try {
      await deleteGoalUseCase(
        goalId: goalId,
        userId: userId,
      );
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}

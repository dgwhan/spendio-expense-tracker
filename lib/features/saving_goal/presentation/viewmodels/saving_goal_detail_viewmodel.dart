import 'package:flutter/foundation.dart';
import 'package:spend_io_app/features/saving_goal/domain/entities/saving_goal_contribution_entity.dart';
import 'package:spend_io_app/features/saving_goal/domain/entities/saving_goal_entity.dart';
import 'package:spend_io_app/features/saving_goal/domain/usecases/add_goal_contribution_usecase.dart';
import 'package:spend_io_app/features/saving_goal/domain/usecases/delete_goal_usecase.dart';
import 'package:spend_io_app/features/saving_goal/domain/usecases/get_goal_by_id_usecase.dart';
import 'package:spend_io_app/features/saving_goal/domain/usecases/get_goal_contributions_usecase.dart';
import 'package:spend_io_app/features/saving_goal/domain/usecases/update_goal_usecase.dart';

class SavingGoalDetailViewModel extends ChangeNotifier {
  final GetGoalByIdUseCase getGoalByIdUseCase;
  final GetGoalContributionsUseCase getGoalContributionsUseCase;
  final AddGoalContributionUseCase addGoalContributionUseCase;
  final UpdateGoalUseCase updateGoalUseCase;
  final DeleteGoalUseCase deleteGoalUseCase;

  SavingGoalDetailViewModel({
    required this.getGoalByIdUseCase,
    required this.getGoalContributionsUseCase,
    required this.addGoalContributionUseCase,
    required this.updateGoalUseCase,
    required this.deleteGoalUseCase,
  });

  SavingGoalEntity? _goal;
  SavingGoalEntity? get goal => _goal;

  List<SavingGoalContributionEntity> _contributions = [];
  List<SavingGoalContributionEntity> get contributions => _contributions;

  bool _loading = false;
  bool get loading => _loading;

  Future<void> loadGoal({required String goalId}) async {
    _loading = true;
    notifyListeners();

    try {
      debugPrint('Loading goal: $goalId');

      _goal = await getGoalByIdUseCase(goalId);
      _contributions = await getGoalContributionsUseCase(goalId);

      debugPrint('Goal loaded: ${_goal?.id}');
    } catch (e, st) {
      debugPrint('loadGoal error: $e');
      debugPrint('$st');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> addContribution({
    required String goalId,
    required SavingGoalContributionEntity contribution,
  }) async {
    debugPrint('Add contribution: ${contribution.amount}');

    await addGoalContributionUseCase(contribution);
    await loadGoal(goalId: goalId);
  }

  Future<void> updateGoal({
    required SavingGoalEntity goal,
  }) async {
    try {
      _loading = true;
      notifyListeners();

      await updateGoalUseCase(goal);

      _goal = goal;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> deleteGoal({
    required String goalId,
    required int userId,
  }) async {
    debugPrint('deleteGoal VM: $goalId');

    await deleteGoalUseCase(
      goalId: goalId,
      userId: userId,
    );

    _goal = null;
    notifyListeners();
  }
}

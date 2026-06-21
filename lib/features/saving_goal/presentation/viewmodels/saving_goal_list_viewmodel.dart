import 'package:flutter/foundation.dart';
import 'package:spend_io_app/features/saving_goal/domain/entities/saving_goal_entity.dart';
import 'package:spend_io_app/features/saving_goal/domain/usecases/get_goals_usecase.dart';

class SavingGoalListViewModel extends ChangeNotifier {
  final GetGoalsUseCase getGoalsUseCase;

  SavingGoalListViewModel({
    required this.getGoalsUseCase,
  });

  List<SavingGoalEntity> _goals = [];

  List<SavingGoalEntity> get goals => _goals;

  bool _loading = false;

  bool get loading => _loading;

  Future<void> loadGoals({
    required int userId,
  }) async {
    _loading = true;
    notifyListeners();

    try {
      _goals = await getGoalsUseCase(
        userId,
      );
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}

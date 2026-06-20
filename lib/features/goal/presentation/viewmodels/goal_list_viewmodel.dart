import 'package:flutter/foundation.dart';
import '../../domain/entities/goal_entity.dart';
import '../../domain/repositories/goal_repository.dart';

class GoalListViewModel extends ChangeNotifier {
  final GoalRepository repository;

  GoalListViewModel(this.repository);

  List<GoalEntity> _goals = [];
  List<GoalEntity> get goals => _goals;

  bool _loading = false;
  bool get loading => _loading;

  Future<void> loadGoals(int userId) async {
    _loading = true;
    notifyListeners();

    _goals = await repository.getGoals(userId);

    _loading = false;
    notifyListeners();
  }
}

import 'package:spend_io_app/features/wallet/domain/entities/saving_goal_entity.dart';
import 'package:spend_io_app/features/wallet/domain/repositories/saving_goal_repository.dart';

class GetGoalsUseCase {
  final SavingGoalRepository repository;

  GetGoalsUseCase(this.repository);

  Future<List<SavingGoalEntity>> call(int localUserId, String remoteUid, {bool forceSync = false}) {
    return repository.getGoals(localUserId, remoteUid, forceSync: forceSync);
  }
}

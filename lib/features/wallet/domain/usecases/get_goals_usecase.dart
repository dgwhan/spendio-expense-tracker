import 'package:spend_io_app/features/wallet/domain/entities/saving_goal_entity.dart';
import 'package:spend_io_app/features/wallet/domain/repositories/wallet_repository.dart';

class GetGoalsUseCase {
  final WalletRepository repository;

  GetGoalsUseCase(this.repository);

  Future<List<SavingGoalEntity>> call(int localUserId, String remoteUid, {bool forceSync = false}) {
    return repository.getGoals(localUserId, remoteUid, forceSync: forceSync);
  }
}

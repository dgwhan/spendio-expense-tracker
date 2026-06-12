import 'package:spend_io_app/features/wallet/domain/entities/saving_goal_entity.dart';
import 'package:spend_io_app/features/wallet/domain/repositories/wallet_repository.dart';

class AddGoalUseCase {
  final WalletRepository repository;

  AddGoalUseCase(this.repository);

  Future<void> call(int localUserId, String remoteUid, SavingGoalEntity goal) {
    return repository.saveGoal(localUserId, remoteUid, goal);
  }
}

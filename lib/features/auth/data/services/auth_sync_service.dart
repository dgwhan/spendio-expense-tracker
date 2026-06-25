import 'package:spend_io_app/features/auth/data/datasource/auth_local_datasource.dart';
import 'package:spend_io_app/features/auth/data/models/user_model.dart';
import 'package:spend_io_app/features/auth/domain/entities/user_entity.dart';

class AuthSyncService {
  final AuthLocalDatasource localDatasource;

  AuthSyncService(this.localDatasource);

  Future<void> syncUser({
    required UserModel userModel,
    double? walletBalance,
    String? firestoreWalletId,
  }) {
    return localDatasource.syncUserFromFirebase(
      userModel,
      walletBalance: walletBalance,
      firestoreWalletId: firestoreWalletId,
    );
  }

  Future<UserEntity?> getUserByEmail(
    String email,
  ) async {
    final users = await localDatasource.getAllUsers();

    try {
      final user = users.firstWhere(
        (e) => e.email == email,
      );

      return user.toEntity();
    } catch (_) {
      return null;
    }
  }

  Future<UserModel?> getUserModelByEmail(
    String email,
  ) async {
    final users = await localDatasource.getAllUsers();

    try {
      return users.firstWhere(
        (e) => e.email == email,
      );
    } catch (_) {
      return null;
    }
  }
}

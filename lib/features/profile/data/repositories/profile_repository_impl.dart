import 'package:spend_io_app/features/profile/data/models/profile_user_model.dart';

import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_local_datasource.dart';
import '../datasources/profile_remote_datasource.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileLocalDataSource localDataSource;
  final ProfileRemoteDataSource remoteDataSource;

  ProfileRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  @override
  Future<ProfileUserEntity?> getCurrentUser() async {
    return null;
  }

  @override
  Future<void> logout() async {
    try {
      await remoteDataSource.signOutFromCloud();
    } finally {
      await localDataSource.clearSessionData();
    }
  }
}

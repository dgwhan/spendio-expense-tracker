import 'package:firebase_auth/firebase_auth.dart';
import 'package:spend_io_app/features/auth/domain/entities/user_entity.dart';
import 'package:spend_io_app/features/profile/data/datasources/profile_local_datasource.dart';
import 'package:spend_io_app/features/profile/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileLocalDataSource localDataSource;
  final FirebaseAuth _firebaseAuth =
      FirebaseAuth.instance; // Remote source trực tiếp

  ProfileRepositoryImpl({required this.localDataSource});

  @override
  Future<UserEntity?> getProfile(int userId) async {
    final userModel = await localDataSource.getUserById(userId);
    return userModel?.toEntity();
  }

  @override
  Future<void> logout() async {
    //ngắt kết nối Session trên Cloud Firebase Auth
    await _firebaseAuth.signOut();
  }
}

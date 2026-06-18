import 'package:spend_io_app/features/auth/domain/entities/user_entity.dart';

abstract class ProfileRepository {
  Future<UserEntity?> getProfile(int userId);
  Future<void> logout();
}

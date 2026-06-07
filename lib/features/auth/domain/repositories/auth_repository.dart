//lớp trừu tượng - định nghĩa hàm

import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<bool> register(UserEntity user);
  Future<UserEntity?> login(String email, String password);
  Future<bool> checkEmailExists(String email);

  Future<UserEntity?> getCurrentUser();
  Future<void> logout();

  Future<void> updateOnboarding({required UserEntity user});
}
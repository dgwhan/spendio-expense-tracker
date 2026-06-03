//bản thực thi của auth_repository (domain), chuyển đổi từ model -> enity rồi trả về domain

import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasource/auth_local_datasource.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalDatasource localDatasource;

  AuthRepositoryImpl(this.localDatasource);

  @override
  Future<bool> register(UserEntity user) async {
    final model = UserModel(
      id: user.id,
      email: user.email,
      password: user.password,
      occupation: user.occupation,
      financialGoal: user.financialGoal,
      currency: user.currency,
      onboardingCompleted: user.onboardingCompleted,
      displayName: user.email.split('@').first,
      createdAt: DateTime.now(),
    );

    return await localDatasource.registerUser(model);
  }

  @override
  Future<UserEntity?> login(String email, String password) async {
    final result = await localDatasource.loginUser(
      email: email,
      password: password,
    );

    if (result == null) return null;

    return UserEntity(
      id: result.id,
      email: result.email,
      password: result.password,
      occupation: result.occupation,
      financialGoal: result.financialGoal,
      currency: result.currency,
      onboardingCompleted: result.onboardingCompleted,
    );
  }

  @override
  Future<bool> checkEmailExists(String email) async {
    final users = await localDatasource.getAllUsers();
    return users.any((e) => e.email == email);
  }

  @override
  Future<UserEntity?> getCurrentUser() {
    throw UnimplementedError();
  }

  @override
  Future<void> logout() {
    throw UnimplementedError();
  }

  @override
  Future<void> updateOnboarding({
    required int userId,
    required String occupation,
    required String financialGoal,
    required String currency,
  }) async {
    await localDatasource.updateOnboarding(
       userId: userId,
       occupation: occupation,
       financialGoal: financialGoal,
       currencyCode: currency,
     );
  }
}
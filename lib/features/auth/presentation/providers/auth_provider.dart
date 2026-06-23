import 'package:flutter/material.dart';
import '../../data/models/user_model.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository repository;

  bool isLoading = false;
  UserModel? currentUser;

  AuthProvider({
    required this.repository,
  });

  Future<String?> register({
    required String email,
    required String password,
  }) async {
    try {
      isLoading = true;
      notifyListeners();

      debugPrint("===> AuthProvider registration request email: $email");

      final userEntity = UserEntity(
        email: email,
        password: password,
        onboardingCompleted: false,
      );

      final success = await repository.register(userEntity);

      if (success) {
        final loginSuccess = await login(email: email, password: password);
        isLoading = false;
        notifyListeners();

        if (loginSuccess) {
          return null;
        } else {
          return "Account created successfully, but auto-login session initialization failed.";
        }
      } else {
        isLoading = false;
        notifyListeners();
        return "Registration failed. Email might already exist or local SQLite storage was rejected.";
      }
    } catch (e) {
      debugPrint("Error inside AuthProvider.register: $e");
      isLoading = false;
      notifyListeners();
      return e.toString();
    }
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    try {
      isLoading = true;
      notifyListeners();

      final result = await repository.login(email, password);

      if (result != null) {
        currentUser = UserModel(
          id: result.id,
          email: result.email,
          password: result.password,
          displayName: result.email.split('@').first,
          occupation: result.occupation,
          financialGoal: result.financialGoal,
          preferredCurrencyCode: result.preferredCurrencyCode,
          onboardingCompleted: result.onboardingCompleted,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      } else {
        currentUser = null;
      }

      isLoading = false;
      notifyListeners();
      return result != null;
    } catch (e) {
      debugPrint("===> Error inside AuthProvider.login: $e");
      currentUser = null;
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> loadSession() async {
    try {
      isLoading = true;
      notifyListeners();

      final result = await repository.getCurrentUser();

      if (result != null) {
        currentUser = UserModel(
          id: result.id,
          email: result.email,
          password: result.password,
          displayName: result.email.split('@').first,
          occupation: result.occupation,
          financialGoal: result.financialGoal,
          preferredCurrencyCode: result.preferredCurrencyCode,
          onboardingCompleted: result.onboardingCompleted,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      } else {
        currentUser = null;
      }
    } catch (e) {
      debugPrint("Error inside AuthProvider.loadSession: $e");
      currentUser = null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void setCurrentUser(UserEntity? user) {
    if (user == null) {
      if (currentUser == null) return;
      currentUser = null;
      notifyListeners();
      return;
    }

    final isSameUser =
        currentUser?.id == user.id && currentUser?.email == user.email;
    if (isSameUser) {
      debugPrint(
          "[AUTH GUARD]: Trùng lặp dữ liệu User. Không cần notifyListeners().");
      return;
    }

    currentUser = UserModel(
      id: user.id,
      email: user.email,
      password: user.password,
      displayName: user.email.split('@').first,
      occupation: user.occupation,
      financialGoal: user.financialGoal,
      preferredCurrencyCode: user.preferredCurrencyCode,
      onboardingCompleted: user.onboardingCompleted,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    notifyListeners();
  }

  Future<void> reloadUser() async {
    if (currentUser == null) return;
    try {
      final result =
          await repository.login(currentUser!.email, currentUser!.password);
      if (result != null) {
        currentUser = UserModel(
          id: result.id,
          email: result.email,
          password: result.password,
          displayName: result.email.split('@').first,
          occupation: result.occupation,
          financialGoal: result.financialGoal,
          preferredCurrencyCode: result.preferredCurrencyCode,
          onboardingCompleted: result.onboardingCompleted,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error inside AuthProvider.reloadUser: $e");
    }
  }

  Future<void> logout() async {
    isLoading = true;
    notifyListeners();

    await repository.logout();
    currentUser = null;

    isLoading = false;
    notifyListeners();
  }
}

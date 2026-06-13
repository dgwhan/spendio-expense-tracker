import 'package:flutter/material.dart';
import '../../data/models/user_model.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';

/// Authentication state provider
class AuthProvider extends ChangeNotifier {
  final AuthRepository repository;

  bool isLoading = false;
  UserModel? currentUser;

  AuthProvider({
    required this.repository,
  });

  /// Register new account
  Future<bool> register({
    required String email,
    required String password,
  }) async {
    try {
      isLoading = true;
      notifyListeners();

      debugPrint("===> AuthProvider nhận email đăng ký: $email");

      final userEntity = UserEntity(
        email: email,
        password: password,
        onboardingCompleted: false,
      );

      final success = await repository.register(userEntity);

      if (success) {
        // Tự động đăng nhập để thiết lập session
        await login(email: email, password: password);
      } else {
        isLoading = false;
        notifyListeners();
      }

      return success;
    } catch (e) {
      //demo tạm thời
      debugPrint("Lỗi tại AuthProvider.register: $e");
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Login existing account
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
          currency: result.currency,
          onboardingCompleted: result.onboardingCompleted,
          createdAt: DateTime.now(),
        );
      } else {
        currentUser = null;
      }

      isLoading = false;
      notifyListeners();

      return result != null;
    } catch (e) {
      debugPrint("===> Lỗi tại AuthProvider.login: $e");
      currentUser = null;
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Load current user session
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
          currency: result.currency,
          onboardingCompleted: result.onboardingCompleted,
          createdAt: DateTime.now(),
        );
      } else {
        currentUser = null;
      }
    } catch (e) {
      debugPrint("Lỗi tại AuthProvider.loadSession: $e");
      currentUser = null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Set user helper
  void setCurrentUser(UserEntity? user) {
    if (user != null) {
      currentUser = UserModel(
        id: user.id,
        email: user.email,
        password: user.password,
        displayName: user.email.split('@').first,
        occupation: user.occupation,
        financialGoal: user.financialGoal,
        currency: user.currency,
        onboardingCompleted: user.onboardingCompleted,
        createdAt: DateTime.now(),
      );
    } else {
      currentUser = null;
    }
    notifyListeners();
  }

  /// Tải lại thông tin User hiện tại từ database
  Future<void> reloadUser() async {
    if (currentUser == null) return;
    try {
      final result = await repository.login(currentUser!.email, currentUser!.password);
      if (result != null) {
        currentUser = UserModel(
          id: result.id,
          email: result.email,
          password: result.password,
          displayName: result.email.split('@').first,
          occupation: result.occupation,
          financialGoal: result.financialGoal,
          currency: result.currency,
          onboardingCompleted: result.onboardingCompleted,
          createdAt: DateTime.now(),
        );
        notifyListeners();
      }
    } catch (e) {
      debugPrint("===> Lỗi tại AuthProvider.reloadUser: $e");
    }
  }

  /// Logout current session
  Future<void> logout() async {
    isLoading = true;
    notifyListeners();

    await repository.logout();
    currentUser = null;

    isLoading = false;
    notifyListeners();
  }
}

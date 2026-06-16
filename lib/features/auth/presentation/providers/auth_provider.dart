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
  /// Returns null if successful, otherwise returns an explicit error message string
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
        // Automatically execute login workflow to initialize session state smoothly
        final loginSuccess = await login(email: email, password: password);

        isLoading = false;
        notifyListeners();

        if (loginSuccess) {
          return null; // Both registration and auto-login completed successfully
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
          createdAt:
              DateTime.now(), // Fallback placeholder if entity layer is raw
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
        updatedAt: DateTime.now(),
      );
    } else {
      currentUser = null;
    }
    notifyListeners();
  }

  /// Reload user session state from database
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
          currency: result.currency,
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

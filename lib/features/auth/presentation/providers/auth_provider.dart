import 'package:flutter/material.dart';
import '../../data/models/user_model.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository repository;

  bool _isEmailLoading = false;
  bool _isGoogleLoading = false;
  bool _isSessionLoading = false;
  bool _isLogoutLoading = false;

  bool get isEmailLoading => _isEmailLoading;
  bool get isGoogleLoading => _isGoogleLoading;
  bool get isSessionLoading => _isSessionLoading;
  bool get isLogoutLoading => _isLogoutLoading;
  bool get isLoading =>
      _isEmailLoading || _isGoogleLoading || _isSessionLoading || _isLogoutLoading;

  UserModel? currentUser;

  AuthProvider({
    required this.repository,
  });

  Future<String?> register({
    required String email,
    required String password,
  }) async {
    try {
      _isEmailLoading = true;
      notifyListeners();

      final userEntity = UserEntity(
        email: email,
        password: password,
        onboardingCompleted: false,
      );

      final success = await repository.register(userEntity);

      if (success) {
        final loginError = await login(email: email, password: password);
        _isEmailLoading = false;
        notifyListeners();

        if (loginError == null) {
          return null;
        } else {
          return loginError;
        }
      } else {
        _isEmailLoading = false;
        notifyListeners();
        return "Registration failed. Email might already exist.";
      }
    } catch (e) {
      _isEmailLoading = false;
      notifyListeners();
      return e.toString();
    }
  }

  Future<String?> login({
    required String email,
    required String password,
  }) async {
    try {
      _isEmailLoading = true;
      notifyListeners();

      final result = await repository.login(email, password);

      if (result != null) {
        currentUser = UserModel(
          id: result.id,
          email: result.email,
          password: result.password,
          displayName: result.displayName,
          occupation: result.occupation,
          financialGoal: result.financialGoal,
          preferredCurrencyCode: result.preferredCurrencyCode,
          onboardingCompleted: result.onboardingCompleted,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        _isEmailLoading = false;
        notifyListeners();
        return null;
      } else {
        currentUser = null;
        _isEmailLoading = false;
        notifyListeners();
        return "Invalid email or password.";
      }
    } catch (e) {
      currentUser = null;
      _isEmailLoading = false;
      notifyListeners();
      return e.toString();
    }
  }

  Future<void> loadSession() async {
    try {
      _isSessionLoading = true;
      notifyListeners();

      final result = await repository.getCurrentUser();

      if (result != null) {
        currentUser = UserModel(
          id: result.id,
          email: result.email,
          password: result.password,
          displayName: result.displayName,
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
      _isSessionLoading = false;
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
      password: user.password ?? '',
      displayName: user.displayName,
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
      final result = await repository.getCurrentUser();
      if (result != null) {
        currentUser = UserModel(
          id: result.id,
          email: result.email,
          password: result.password,
          displayName: result.displayName,
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
    _isLogoutLoading = true;
    notifyListeners();

    await repository.logout();
    currentUser = null;

    _isLogoutLoading = false;
    notifyListeners();
  }

  /// Signs in the user with Google.
  ///
  /// Returns `null` on success, or an error message string on failure.
  /// Returns `null` silently when the user cancels the Google picker
  /// (no error dialog should be shown in that case — check [currentUser]).
  Future<String?> signInWithGoogle() async {
    if (isLoading) return null;

    try {
      _isGoogleLoading = true;
      notifyListeners();

      final result = await repository.signInWithGoogle();

      // User cancelled the picker — not an error
      if (result == null) {
        _isGoogleLoading = false;
        notifyListeners();
        return null;
      }

      // Success — set current user exactly like login() does
      currentUser = UserModel(
        id: result.id,
        email: result.email,
        password: result.password,
        displayName: result.displayName,
        occupation: result.occupation,
        financialGoal: result.financialGoal,
        preferredCurrencyCode: result.preferredCurrencyCode,
        onboardingCompleted: result.onboardingCompleted,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      _isGoogleLoading = false;
      notifyListeners();
      return null; // null = success
    } catch (e) {
      currentUser = null;
      _isGoogleLoading = false;
      notifyListeners();
      debugPrint('[AuthProvider] Google Sign-In error: $e');
      return e.toString();
    }
  }
}

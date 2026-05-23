import 'package:flutter/material.dart';

import '../../data/datasource/auth_local_datasource.dart';
import '../../data/models/user_model.dart';

/// authentication state provider
class AuthProvider extends ChangeNotifier {
  final AuthLocalDatasource
      _datasource =
      AuthLocalDatasource();

  bool isLoading = false;

  UserModel? currentUser;

  /// register new account
  Future<bool> register({
    required String email,
    required String password,
  }) async {
    try {
      isLoading = true;

      notifyListeners();

      final emailName =
          email.split('@').first;

      final displayName =
          emailName[0]
                  .toUpperCase() +
              emailName.substring(1);

      final user = UserModel(
        email: email,
        password: password,
        displayName: displayName,
        createdAt: DateTime.now(),
      );

      final success =
          await _datasource
              .registerUser(user);

      isLoading = false;

      notifyListeners();

      return success;
    } catch (e) {
      isLoading = false;

      notifyListeners();

      return false;
    }
  }

  /// login existing account
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    isLoading = true;

    notifyListeners();

    final result =
        await _datasource.loginUser(
      email: email,
      password: password,
    );

    currentUser = result;

    isLoading = false;

    notifyListeners();

    return result != null;
  }

  /// load current user session
  Future<void> loadSession() async {
    currentUser =
        await _datasource
            .getCurrentUser();

    notifyListeners();
  }

  /// logout current session
  Future<void> logout() async {
    await _datasource.logout();

    currentUser = null;

    notifyListeners();
  }
}
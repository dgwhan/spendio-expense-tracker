import 'package:flutter/material.dart';
import '../../data/datasource/auth_local_datasource.dart';
import '../../data/models/user_model.dart';

/// Authentication state provider
class AuthProvider extends ChangeNotifier {
  final AuthLocalDatasource _datasource = AuthLocalDatasource();

  bool isLoading = false;
  UserModel? currentUser;

  /// Register new account
  Future<bool> register({
    required String email,
    required String password,
  }) async {
    try {
      isLoading = true;
      notifyListeners();

      // Debug xem email thực tế truyền vào hàm này là gì
      debugPrint("===> AuthProvider nhận email đăng ký: $email");

      final emailName = email.split('@').first;
      final displayName = emailName.isEmpty
          ? 'User'
          : emailName[0].toUpperCase() + emailName.substring(1);

      final user = UserModel(
        email: email,
        password: password,
        displayName: displayName,
        createdAt: DateTime.now(),
      );

      // Gọi xuống datasource local để lưu
      final success = await _datasource.registerUser(user);

      isLoading = false;
      notifyListeners();

      return success;
    } catch (e) {
      debugPrint("===> Lỗi tại AuthProvider.register: $e");
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
    isLoading = true;
    notifyListeners();

    final result = await _datasource.loginUser(
      email: email,
      password: password,
    );

    currentUser = result;
    isLoading = false;
    notifyListeners();

    return result != null;
  }

  /// Load current user session
  Future<void> loadSession() async {
    currentUser = await _datasource.getCurrentUser();
    notifyListeners();
  }

  /// Logout current session
  Future<void> logout() async {
    await _datasource.logout();
    currentUser = null;
    notifyListeners();
  }
}

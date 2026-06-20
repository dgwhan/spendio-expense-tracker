import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:spend_io_app/core/database/app_database.dart';
import 'package:spend_io_app/features/auth/domain/entities/user_entity.dart';
import 'package:spend_io_app/features/profile/domain/repositories/profile_repository.dart';
import 'package:spend_io_app/features/profile/domain/usecase/update_app_settings_usecase.dart';

class ProfileViewModel extends ChangeNotifier {
  final ProfileRepository profileRepository;
  final UpdateAppSettingsUseCase updateAppSettingsUseCase;

  bool _isLoading = false;
  UserEntity? _user;
  bool _isDarkMode = false;
  String _currentLanguage = 'en';

  bool get isLoading => _isLoading;
  UserEntity? get user => _user;
  bool get isDarkMode => _isDarkMode;
  String get currentLanguage => _currentLanguage;

  ProfileViewModel({
    required this.profileRepository,
    required this.updateAppSettingsUseCase,
  });

  Future<void> loadCurrentUser() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null || currentUser.email == null) {
      debugPrint(
          '[Profile VM Error]: No authenticated session found in Firebase.');
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final db = await AppDatabase.database;
      final result = await db.query(
        'users',
        where: 'email = ?',
        whereArgs: [currentUser.email],
        limit: 1,
      );

      if (result.isNotEmpty) {
        final map = result.first;
        _user = UserEntity(
          id: map['id'] as int?,
          email: map['email'] as String,
          password: map['password'] as String? ?? '',
          occupation: map['occupation'] as String?,
          financialGoal: map['financial_goal'] as String?,
          currency: map['currency_code'] as String?,
          onboardingCompleted: (map['onboarding_completed'] as int? ?? 0) == 1,
        );
        debugPrint(
            '[Profile VM Success]: Successfully mapped entity for ${currentUser.email}');
      }
    } catch (e) {
      debugPrint('[Profile VM Error]: Failed to load and map user profile: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleTheme(bool value) async {
    _isDarkMode = value;
    notifyListeners();

    await updateAppSettingsUseCase
        .execute(AppSettingsParams(isDarkMode: value));
    debugPrint(
        '[Theme Pipeline]: VM state dispatch complete via usecase block.');
  }

  Future<void> changeLanguage(String languageCode) async {
    _currentLanguage = languageCode;
    notifyListeners();

    await updateAppSettingsUseCase
        .execute(AppSettingsParams(languageCode: languageCode));
    debugPrint(
        '[Locale Pipeline]: VM locale dispatch complete via usecase block.');
  }

  void updateUser(UserEntity? newUser) {
    _user = newUser;
    notifyListeners();
  }

  Future<bool> handleLogout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await profileRepository.logout();
      await AppDatabase.close();

      _user = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('[Profile VM Error]: Logout processing failed: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:spend_io_app/core/database/app_database.dart';
import 'package:spend_io_app/core/utils/localization.dart';
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
          preferredCurrencyCode: map['preferred_currency_code'] as String?,
          onboardingCompleted: (map['onboarding_completed'] as int? ?? 0) == 1,
          displayNameField: map['display_name'] as String?,
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
    AppLocalizations.currentLanguage = languageCode;
    notifyListeners();

    await updateAppSettingsUseCase
        .execute(AppSettingsParams(languageCode: languageCode));
    debugPrint(
        '[Locale Pipeline]: VM locale dispatch complete via usecase block.');
  }

  Future<bool> updateUserProfile({
    required String displayName,
    required String occupation,
    required String financialGoal,
    required String currency,
  }) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null || currentUser.email == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      final db = await AppDatabase.database;
      await db.update(
        'users',
        {
          'display_name': displayName,
          'occupation': occupation,
          'financial_goal': financialGoal,
          'preferred_currency_code': currency,
          'updated_at': DateTime.now().toIso8601String(),
        },
        where: 'email = ?',
        whereArgs: [currentUser.email],
      );

      await loadCurrentUser();
      return true;
    } catch (e) {
      debugPrint('[Profile VM Error]: Failed to update user profile: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
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
      // await AppDatabase.close();

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

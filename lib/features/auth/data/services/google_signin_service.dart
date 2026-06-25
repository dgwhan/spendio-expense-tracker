import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/foundation.dart';
import 'package:spend_io_app/features/auth/data/services/auth_sync_service.dart';
import 'package:spend_io_app/features/auth/data/datasource/auth_local_datasource.dart';
import 'package:spend_io_app/features/auth/data/datasource/auth_remote_datasource.dart';
import 'package:spend_io_app/features/auth/data/datasource/google_auth_datasource.dart';
import 'package:spend_io_app/features/auth/data/models/user_model.dart';
import 'package:spend_io_app/features/auth/domain/entities/user_entity.dart';

class GoogleSigninService {
  final GoogleAuthDatasource googleAuthDatasource;
  final AuthRemoteDatasource remoteDatasource;
  final AuthLocalDatasource localDatasource;
  final AuthSyncService authSyncService;

  GoogleSigninService({
    required this.googleAuthDatasource,
    required this.remoteDatasource,
    required this.localDatasource,
    required this.authSyncService,
  });

  Future<UserEntity?> signIn() async {
    fb.UserCredential? credential;

    try {
      credential = await googleAuthDatasource.signInWithGoogle().timeout(
            const Duration(seconds: 30),
          );
    } catch (e) {
      debugPrint(
        '[GoogleSigninService] Google Sign-In error: $e',
      );

      final cachedUser = fb.FirebaseAuth.instance.currentUser;

      if (cachedUser != null) {
        return _resolveGoogleUser(
          cachedUser,
        );
      }

      return null;
    }

    if (credential == null) {
      return null;
    }

    final user = credential.user;

    if (user == null) {
      return null;
    }

    return _resolveGoogleUser(
      user,
    );
  }

  Future<UserEntity?> _resolveGoogleUser(
    fb.User fbUser,
  ) async {
    final uid = fbUser.uid;

    final email = fbUser.email ?? '';

    final displayName = fbUser.displayName ?? email.split('@').first;

    try {
      await remoteDatasource.createGoogleUserIfNotExists(
        uid: uid,
        email: email,
        displayName: displayName,
      );

      final profile = await remoteDatasource.loadUserProfile(
        uid: uid,
      );

      final localModel = UserModel(
        email: email,
        password: '',
        displayName: profile.userData['display_name'] as String? ?? displayName,
        occupation: profile.userData['occupation'] as String?,
        financialGoal: profile.userData['financial_goal'] as String?,
        preferredCurrencyCode:
            profile.userData['preferred_currency_code'] as String? ??
                profile.userData['currency_code'] as String?,
        onboardingCompleted: profile.userData['onboarding_completed'] == 1,
        createdAt: profile.userData['created_at'] != null
            ? DateTime.tryParse(
                  profile.userData['created_at'] as String,
                ) ??
                DateTime.now()
            : DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await authSyncService.syncUser(
        userModel: localModel,
        walletBalance: profile.walletBalance,
        firestoreWalletId: profile.firestoreWalletId,
      );

      return await authSyncService.getUserByEmail(
        email,
      );
    } catch (e) {
      debugPrint(
        '[GoogleSigninService] Resolve Google user failed: $e',
      );

      final users = await localDatasource.getAllUsers();

      try {
        return users
            .firstWhere(
              (e) => e.email == email,
            )
            .toEntity();
      } catch (_) {
        return null;
      }
    }
  }
}

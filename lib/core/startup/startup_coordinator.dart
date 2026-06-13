import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:spend_io_app/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:spend_io_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:spend_io_app/features/wallet/domain/usecases/check_wallet_initialization_usecase.dart';
import 'startup_result.dart';

class StartupCoordinator {
  final GetCurrentUserUseCase getCurrentUserUseCase;
  final CheckWalletInitializationUseCase checkWalletInitializationUseCase;
  final AuthProvider authProvider;

  StartupCoordinator({
    required this.getCurrentUserUseCase,
    required this.checkWalletInitializationUseCase,
    required this.authProvider,
  });

  Future<StartupResult> resolve() async {
    // 1. GetCurrentUserUseCase
    final user = await getCurrentUserUseCase();

    if (user == null) {
      authProvider.setCurrentUser(null);
      return StartupResult.login;
    }

    // Sync session to AuthProvider
    authProvider.setCurrentUser(user);

    final userId = user.id;
    if (userId == null) {
      return StartupResult.login;
    }

    // Get remote UID from firebase auth
    final firebaseUser = fb.FirebaseAuth.instance.currentUser;
    final remoteUid = firebaseUser?.uid ?? '';

    // 2. CheckWalletInitializationUseCase
    final isInitialized = await checkWalletInitializationUseCase(userId, remoteUid);
    if (isInitialized || user.onboardingCompleted) {
      return StartupResult.home;
    }

    return StartupResult.onboarding;
  }
}

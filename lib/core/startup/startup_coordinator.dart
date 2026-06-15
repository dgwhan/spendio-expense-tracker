import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/foundation.dart';
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
    try {
      // Lấy thông tin user hiện tại với thời gian chờ tối đa 3 giây tránh treo local DB
      final user = await getCurrentUserUseCase().timeout(
        const Duration(seconds: 3),
        onTimeout: () {
          debugPrint("⏳ Timeout: getCurrentUserUseCase quá lâu -> Ép về Login");
          return null;
        },
      );

      // Kiểm tra bẫy an toàn: xử lý chặt chẽ trường hợp user rỗng hoặc id null khi clear DB
      if (user == null || user.id == null) {
        authProvider.setCurrentUser(null);
        return StartupResult.login;
      }

      // Sync session to AuthProvider
      authProvider.setCurrentUser(user);

      final int nonNullUserId = user.id!;

      // 2. Lấy remote UID từ Firebase Auth
      final firebaseUser = fb.FirebaseAuth.instance.currentUser;
      final remoteUid = firebaseUser?.uid ?? '';

      if (remoteUid.trim().isEmpty) {
        debugPrint(
            "ℹFirebase UID rỗng (Đã đăng xuất) -> Chuyển hướng về Login");
        authProvider.setCurrentUser(null);
        return StartupResult.login;
      }

      final isInitialized =
          await checkWalletInitializationUseCase(nonNullUserId, remoteUid)
              .timeout(
        const Duration(seconds: 3),
        onTimeout: () {
          debugPrint(
              "Timeout: Kiểm tra khởi tạo ví quá lâu -> Mặc định về Onboarding");
          return false;
        },
      );

      if (isInitialized || user.onboardingCompleted) {
        return StartupResult.home;
      }

      return StartupResult.onboarding;
    } catch (e) {
      debugPrint("Lỗi xảy ra trong tiến trình StartupCoordinator: $e");
      authProvider.setCurrentUser(null);
      return StartupResult.login;
    }
  }
}

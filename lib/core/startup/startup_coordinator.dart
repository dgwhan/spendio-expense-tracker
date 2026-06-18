import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spend_io_app/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:spend_io_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:spend_io_app/features/wallet/domain/usecases/check_wallet_initialization_usecase.dart';
import 'package:spend_io_app/features/transaction/presentation/viewmodels/transaction_viewmodel.dart';
import 'package:spend_io_app/features/wallet/presentation/viewmodels/wallet_viewmodel.dart';
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

  Future<StartupResult> resolve(BuildContext context) async {
    debugPrint("[STARTUP DIAGNOSTIC] === BẮT ĐẦU TIẾN TRÌNH KHỞI ĐỘNG APP ===");
    try {
      debugPrint(
          "[STARTUP DIAGNOSTIC] Bước 1: Đang gọi getCurrentUserUseCase()...");
      final user = await getCurrentUserUseCase().timeout(
        const Duration(seconds: 3),
        onTimeout: () {
          debugPrint(
              "⏳ [STARTUP WORKER] Timeout: getCurrentUserUseCase bị treo -> Hướng về Login");
          return null;
        },
      );

      debugPrint(
          "[STARTUP DIAGNOSTIC] Kết quả User: ${user?.email ?? 'RỖNG'} (ID: ${user?.id ?? 'NULL'})");

      if (user == null || user.id == null) {
        debugPrint(
            "[STARTUP DIAGNOSTIC] Không tìm thấy session User -> Hướng về LOGIN");
        authProvider.setCurrentUser(null);
        return StartupResult.login;
      }

      debugPrint(
          "[STARTUP DIAGNOSTIC] Bước 2: Kiểm tra Firebase Auth Instance...");
      final firebaseUser = fb.FirebaseAuth.instance.currentUser;
      final remoteUid = firebaseUser?.uid ?? '';
      debugPrint("[STARTUP DIAGNOSTIC] Firebase Remote UID: '$remoteUid'");

      if (remoteUid.trim().isEmpty) {
        debugPrint(
            "[STARTUP DIAGNOSTIC] Firebase Session rỗng -> Hướng về LOGIN");
        authProvider.setCurrentUser(null);
        return StartupResult.login;
      }

      debugPrint(
          "[STARTUP DIAGNOSTIC] Bước 3: Đang gọi checkWalletInitializationUseCase...");
      final int nonNullUserId = user.id!;
      final isInitialized =
          await checkWalletInitializationUseCase(nonNullUserId, remoteUid)
              .timeout(
        const Duration(seconds: 3),
        onTimeout: () {
          debugPrint(
              "[STARTUP WORKER] Timeout: CheckWalletInitialization bị treo -> Ép về Onboarding");
          return false;
        },
      );

      debugPrint(
          "[STARTUP DIAGNOSTIC] Trạng thái ví khởi tạo: $isInitialized, Onboarding hoàn thành: ${user.onboardingCompleted}");

      if (isInitialized || user.onboardingCompleted) {
        if (context.mounted) {
          debugPrint(
              "[STARTUP DIAGNOSTIC] Bước 4: Đồng bộ duy nhất qua AuthProvider...");
          authProvider.setCurrentUser(user);

          final walletVM = context.read<WalletViewModel>();
          debugPrint(
              "[STARTUP DIAGNOSTIC] Chờ luồng Ví nạp xong cấu trúc cơ sở ngầm...");
          await walletVM.initialize().timeout(
            const Duration(seconds: 4),
            onTimeout: () {
              debugPrint(
                  "⏳ [STARTUP WARNING]: Khởi tạo Ví mất quá nhiều thời gian, bỏ qua để vào Home.");
            },
          );

          debugPrint(
              "[STARTUP DIAGNOSTIC] Bước 5: Đang nạp lịch sử giao dịch qua transactionViewModel...");
          await context
              .read<TransactionViewModel>()
              .loadAllTransactions()
              .timeout(
            const Duration(seconds: 4),
            onTimeout: () {
              debugPrint(
                  "[CRITICAL BUG FOUND] Hàm transactionViewModel.loadAllTransactions() BỊ TREO HOÀN TOÀN!");
              throw TimeoutException("Treo tại TransactionVM");
            },
          );
          debugPrint("[STARTUP DIAGNOSTIC] Load lịch sử giao dịch THÀNH CÔNG!");
        }

        debugPrint(
            "[STARTUP DIAGNOSTIC] === LUỒNG ĐI QUA SẠCH SẼ -> ĐIỀU HƯỚNG VỀ HOME ===");
        return StartupResult.home;
      }

      debugPrint("[STARTUP DIAGNOSTIC] Điều hướng về ONBOARDING");
      return StartupResult.onboarding;
    } catch (e, stack) {
      debugPrint(
          "[STARTUP CRASH REPORT] BẮT ĐƯỢC THỦ PHẠM KHIẾN APP ĐỨNG IM: $e");
      debugPrintStack(stackTrace: stack);
      authProvider.setCurrentUser(null);
      return StartupResult.login;
    }
  }
}

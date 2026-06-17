import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spend_io_app/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:spend_io_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:spend_io_app/features/wallet/domain/usecases/check_wallet_initialization_usecase.dart';
import 'package:spend_io_app/features/wallet/presentation/viewmodels/wallet_viewmodel.dart';
import 'package:spend_io_app/features/transaction/presentation/viewmodels/transaction_viewmodel.dart';
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
    debugPrint("[DIAGNOSTIC] === BẮT ĐẦU TIẾN TRÌNH KHỞI ĐỘNG APP ===");
    try {
      debugPrint("[DIAGNOSTIC] Bước 1: Đang gọi getCurrentUserUseCase()...");
      final user = await getCurrentUserUseCase().timeout(
        const Duration(seconds: 3),
        onTimeout: () {
          debugPrint(
              "⏳ [DIAGNOSTIC WORKER] Timeout: getCurrentUserUseCase bị treo -> Ép về Login");
          return null;
        },
      );
      debugPrint(
          "[DIAGNOSTIC] Kết quả User: ${user?.email ?? 'RỖNG'} (ID: ${user?.id ?? 'NULL'})");

      if (user == null || user.id == null) {
        debugPrint(
            "[DIAGNOSTIC] Không tìm thấy session User -> Hướng về LOGIN");
        authProvider.setCurrentUser(null);
        return StartupResult.login;
      }

      debugPrint("[DIAGNOSTIC] Bước 2: Đang đồng bộ user vào AuthProvider...");
      authProvider.setCurrentUser(user);
      final int nonNullUserId = user.id!;

      debugPrint("[DIAGNOSTIC] Bước 3: Kiểm tra Firebase Auth Instance...");
      final firebaseUser = fb.FirebaseAuth.instance.currentUser;
      final remoteUid = firebaseUser?.uid ?? '';
      debugPrint("[DIAGNOSTIC] Firebase Remote UID: '$remoteUid'");

      if (remoteUid.trim().isEmpty) {
        debugPrint("[DIAGNOSTIC] Firebase Session rỗng -> Hướng về LOGIN");
        authProvider.setCurrentUser(null);
        return StartupResult.login;
      }

      debugPrint(
          "[DIAGNOSTIC] Bước 4: Đang gọi checkWalletInitializationUseCase...");
      final isInitialized =
          await checkWalletInitializationUseCase(nonNullUserId, remoteUid)
              .timeout(
        const Duration(seconds: 3),
        onTimeout: () {
          debugPrint(
              "[DIAGNOSTIC WORKER] Timeout: CheckWalletInitialization bị treo -> Ép về Onboarding");
          return false;
        },
      );
      debugPrint(
          "[DIAGNOSTIC] Trạng thái ví khởi tạo: $isInitialized, Onboarding hoàn thành: ${user.onboardingCompleted}");

      if (isInitialized || user.onboardingCompleted) {
        if (context.mounted) {
          debugPrint(
              "[DIAGNOSTIC LÕI] TIẾN HÀNH NẠP ĐÈ DỮ LIỆU ĐỂ BẮT BUG TREO:");

          final walletVM = context.read<WalletViewModel>();
          debugPrint("[DIAGNOSTIC WORKER] Đang gọi walletVM.updateUser()...");
          walletVM.updateUser(user);

          debugPrint(
              "[DIAGNOSTIC WORKER] Đang nạp dữ liệu Ví qua walletVM.initialize()...");
          await walletVM.initialize().timeout(
            const Duration(seconds: 4),
            onTimeout: () {
              debugPrint(
                  "[CRITICAL BUG FOUND] Hàm walletViewModel.initialize() BỊ TREO VĨNH VIỄN TẠI SQL/FIREBASE!");
              throw TimeoutException("Treo tại WalletVM");
            },
          );
          debugPrint("[DIAGNOSTIC] walletVM.initialize() chạy THÀNH CÔNG!");

          debugPrint(
              "[DIAGNOSTIC WORKER] Đang nạp lịch sử trans qua transactionViewModel.loadAllTransactions()...");
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
          debugPrint("[DIAGNOSTIC] Load lịch sử giao dịch THÀNH CÔNG!");
        }

        debugPrint(
            "[DIAGNOSTIC] === LUỒNG ĐI QUA SẠCH SẼ -> ĐIỀU HƯỚNG VỀ HOME ===");
        return StartupResult.home;
      }

      debugPrint("[DIAGNOSTIC] Điều hướng về ONBOARDING");
      return StartupResult.onboarding;
    } catch (e, stack) {
      debugPrint(
          "[DASHBOARD CRASH REPORT] BẮT ĐƯỢC THỦ PHẠM KHIẾN APP ĐỨNG IM: $e");
      debugPrintStack(stackTrace: stack);
      authProvider.setCurrentUser(null);
      return StartupResult.login;
    }
  }
}

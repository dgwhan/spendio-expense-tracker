import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/material.dart';
import 'package:spend_io_app/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:spend_io_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:spend_io_app/features/category/domain/repositories/category_repository.dart';
import 'package:spend_io_app/features/category/presentation/viewmodels/category_viewmodel.dart';
import 'package:spend_io_app/features/transaction/domain/usecases/initialize_transaction_categories_usecase.dart';
import 'package:spend_io_app/features/wallet/domain/usecases/check_wallet_initialization_usecase.dart';
import 'package:spend_io_app/features/transaction/presentation/viewmodels/transaction_viewmodel.dart';
import 'package:spend_io_app/features/wallet/presentation/viewmodels/wallet_viewmodel.dart';
import 'package:spend_io_app/features/profile/presentation/viewmodels/profile_viewmodel.dart';

import 'startup_result.dart';

class StartupCoordinator {
  final GetCurrentUserUseCase getCurrentUserUseCase;
  final CheckWalletInitializationUseCase checkWalletInitializationUseCase;
  final AuthProvider authProvider;

  final CategoryRepository categoryRepository;
  final ProfileViewModel profileVM;
  final WalletViewModel walletVM;
  final CategoryViewModel categoryVM;
  final TransactionViewModel transactionVM;

  StartupCoordinator({
    required this.getCurrentUserUseCase,
    required this.checkWalletInitializationUseCase,
    required this.authProvider,
    required this.categoryRepository,
    required this.profileVM,
    required this.walletVM,
    required this.categoryVM,
    required this.transactionVM,
  });

  void _log(String msg) {
    debugPrint("[STARTUP] $msg");
  }

  Future<StartupResult> resolve(BuildContext context) async {
    _log("=== STARTUP BEGIN ===");

    try {
      // INIT DEFAULT CATEGORIES
      _log("Init default categories...");
      try {
        final initCategoriesUseCase =
            InitializeTransactionCategoriesUseCase(categoryRepository);

        await initCategoriesUseCase.call();
      } catch (e) {
        _log("Category init error: $e");
      }

      // LOCAL USER CHECK
      _log("Checking local user...");
      final user = await getCurrentUserUseCase().timeout(
        const Duration(seconds: 3),
        onTimeout: () {
          _log("Timeout getCurrentUser -> LOGIN");
          return null;
        },
      );

      _log("User loaded: ${user?.email ?? 'NULL'}");

      if (user == null || user.id == null) {
        authProvider.setCurrentUser(null);
        return StartupResult.login;
      }

      // FIREBASE CHECK
      final firebaseUser = fb.FirebaseAuth.instance.currentUser;
      final remoteUid = firebaseUser?.uid ?? '';

      _log("Firebase UID: $remoteUid");

      if (remoteUid.isEmpty) {
        authProvider.setCurrentUser(null);
        return StartupResult.login;
      }

      // WALLET INITIALIZATION CHECK
      final isInitialized =
          await checkWalletInitializationUseCase(user.id!).timeout(
        const Duration(seconds: 3),
        onTimeout: () {
          _log("Wallet check timeout -> onboarding fallback");
          return false;
        },
      );

      _log("Wallet initialized: $isInitialized");

      // HOME FLOW
      if (isInitialized || user.onboardingCompleted) {
        authProvider.setCurrentUser(user);

        await profileVM.loadCurrentUser();

        await walletVM.initialize().timeout(
              const Duration(seconds: 4),
              onTimeout: () => _log("Wallet init timeout skip"),
            );

        await categoryVM.loadCategories(user.id!).timeout(
              const Duration(seconds: 4),
              onTimeout: () => _log("Category load timeout skip"),
            );

        await transactionVM.loadAllTransactions().timeout(
              const Duration(seconds: 4),
              onTimeout: () => _log("Transaction load timeout skip"),
            );

        _log("SUCCESS → HOME");
        return StartupResult.home;
      }

      _log("GO -> ONBOARDING");
      return StartupResult.onboarding;
    } catch (e, s) {
      _log("CRASH: $e");
      debugPrintStack(stackTrace: s);
      authProvider.setCurrentUser(null);
      return StartupResult.login;
    }
  }
}

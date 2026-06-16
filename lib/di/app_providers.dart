import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:spend_io_app/core/startup/startup_coordinator.dart';
import 'package:spend_io_app/di/account_provider.dart';
import 'package:spend_io_app/di/auth_provider.dart';
import 'package:spend_io_app/di/onboarding_provider.dart';
import 'package:spend_io_app/di/profile_provider.dart';
import 'package:spend_io_app/di/wallet_provider.dart';
import 'package:spend_io_app/di/transaction_provider.dart'; // 1. IMPORT FILE DI PHASE 03 VÀO ĐÂY

import 'package:spend_io_app/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:spend_io_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:spend_io_app/features/wallet/domain/usecases/check_wallet_initialization_usecase.dart';

class AppProviders {
  AppProviders._();

  static List<SingleChildWidget> get providers => [
        ...AuthModuleProvider.providers,
        ...OnboardingModuleProvider.providers,
        ...AccountProvider.providers,
        ...WalletModuleProvider.providers,
        ...ProfileModuleProvider.providers,

        // ĐĂNG KÝ TRANSACTION PROVIDERS TẠI ĐÂY
        ...TransactionProvider.providers,

        // CORE ORCHESTRATION ENGINE (STARTUP COORDINATOR)
        ProxyProvider2<AuthProvider, CheckWalletInitializationUseCase,
            StartupCoordinator>(
          update: (context, authProvider, checkWalletInit, previous) =>
              previous ??
              StartupCoordinator(
                authProvider: authProvider,
                checkWalletInitializationUseCase: checkWalletInit,
                getCurrentUserUseCase: context.read<GetCurrentUserUseCase>(),
              ),
        ),
      ];
}

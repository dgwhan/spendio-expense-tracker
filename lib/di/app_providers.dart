import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:spend_io_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:sqflite/sqflite.dart';

import 'package:spend_io_app/core/startup/startup_coordinator.dart';

import 'package:spend_io_app/di/auth_provider.dart';
import 'package:spend_io_app/di/account_provider.dart';
import 'package:spend_io_app/di/onboarding_provider.dart';
import 'package:spend_io_app/di/category_provider.dart';
import 'package:spend_io_app/di/transaction_provider.dart';
import 'package:spend_io_app/di/budget_provider.dart';
import 'package:spend_io_app/di/wallet_provider.dart';
import 'package:spend_io_app/di/profile_provider.dart';

import 'package:spend_io_app/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:spend_io_app/features/wallet/domain/usecases/check_wallet_initialization_usecase.dart';

class AppProviders {
  AppProviders._();

  static List<SingleChildWidget> providers(Database database) {
    return [
      // CORE

      Provider<Database>.value(value: database),

      // AUTH + BOOTSTRAP LOW LEVEL
      ...AuthModuleProvider.providers,
      ...OnboardingModuleProvider.providers,

      // DOMAIN FEATURES
      ...AccountModuleProvider.providers,
      ...CategoryModuleProvider.providers,

      // TRANSACTION
      ...TransactionProvider.providers,

      // BUDGET
      ...BudgetModuleProvider.providers,

      // WALLET + PROFILE
      ...WalletModuleProvider.providers,
      ...ProfileModuleProvider.providers,

      // =========================================================
      // STARTUP ORCHESTRATOR
      // =========================================================
      ProxyProvider2<AuthProvider, CheckWalletInitializationUseCase,
          StartupCoordinator>(
        update: (context, auth, walletCheck, previous) {
          return previous ??
              StartupCoordinator(
                authProvider: auth,
                checkWalletInitializationUseCase: walletCheck,
                getCurrentUserUseCase: context.read<GetCurrentUserUseCase>(),
              );
        },
      ),
    ];
  }
}

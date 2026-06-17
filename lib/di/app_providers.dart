import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:spend_io_app/core/database/app_database.dart';
import 'package:spend_io_app/core/startup/startup_coordinator.dart';
import 'package:spend_io_app/di/account_provider.dart'; // Khôi phục import
import 'package:spend_io_app/di/auth_provider.dart';
import 'package:spend_io_app/di/category_provider.dart'; // Khôi phục import
import 'package:spend_io_app/di/onboarding_provider.dart';
import 'package:spend_io_app/di/profile_provider.dart';
import 'package:spend_io_app/di/transaction_provider.dart';
import 'package:spend_io_app/di/wallet_provider.dart';
import 'package:spend_io_app/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:spend_io_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:spend_io_app/features/wallet/domain/usecases/check_wallet_initialization_usecase.dart';
import 'package:sqflite/sqflite.dart';

class AppProviders {
  AppProviders._();

  static List<SingleChildWidget> get providers => [
        Provider<Future<Database>>(
          create: (_) => AppDatabase.database,
          lazy: false,
        ),

        ...AuthModuleProvider.providers,
        ...OnboardingModuleProvider.providers,
        ...AccountProvider.providers,
        ...CategoryProvider.providers,
        ...TransactionProvider.providers,
        ...WalletModuleProvider.providers,
        ...ProfileModuleProvider.providers,

        // CORE ORCHESTRATION ENGINE
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

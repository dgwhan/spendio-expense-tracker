import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:spend_io_app/features/onboarding/domain/repositories/onboarding_repository.dart';
import 'package:spend_io_app/features/wallet/data/datasources/wallet_remote_data_source.dart';
import 'package:spend_io_app/features/wallet/presentation/viewmodels/wallet_viewmodel.dart';
import '../../../features/home/presentation/viewmodels/dashboard_viewmodel.dart';

// PROFILE LAYER
import 'package:spend_io_app/features/profile/data/datasources/profile_local_datasource.dart';
import 'package:spend_io_app/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:spend_io_app/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:spend_io_app/features/profile/presentation/viewmodels/profile_viewmodel.dart';

// ONBOARDING LAYER
import '../features/onboarding/data/datasources/onboarding_local_datasource.dart';
import '../features/onboarding/data/datasources/onboarding_remote_datasource.dart';
import '../features/onboarding/data/repositories/onboarding_repository_impl.dart';
import '../../../features/onboarding/domain/usecases/save_onboarding_usecase.dart';
import '../../../features/onboarding/domain/usecases/get_onboarding_usecase.dart';
import '../../../features/onboarding/domain/usecases/check_onboarding_usecase.dart';
import '../../../features/onboarding/domain/usecases/complete_onboarding_usecase.dart';
import '../../../features/onboarding/presentation/viewmodels/onboarding_viewmodel.dart';

// AUTH LAYER
import '../../../features/auth/data/datasource/auth_local_datasource.dart';
import '../../../features/auth/data/datasource/auth_remote_datasource.dart';
import '../../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../../features/auth/domain/usecases/check_email_usecase.dart';
import '../../../features/auth/domain/usecases/get_current_user_usecase.dart';
import '../../../features/auth/presentation/viewmodels/register_form_viewmodel.dart';
import '../../../features/auth/presentation/viewmodels/login_form_viewmodel.dart';
import '../../../features/auth/presentation/providers/auth_provider.dart';
import '../core/startup/startup_coordinator.dart';

// WALLET LAYER
import '../features/wallet/data/datasources/wallet_local_data_source.dart';
import '../features/account/data/datasource/account_local_data_source.dart';
import '../features/account/data/datasource/account_remote_data_source.dart';
import '../features/wallet/data/datasources/goal/goal_local_data_source.dart';
import '../features/wallet/data/datasources/goal/goal_remote_data_source.dart';
import '../features/wallet/data/datasources/budget/budget_local_data_source.dart';
import '../../../features/wallet/data/repositories/wallet_repository_impl.dart';
import '../features/account/data/repositories/account_repository_impl.dart';
import '../../../features/wallet/data/repositories/saving_goal_repository_impl.dart';
import '../../../features/wallet/data/repositories/budget_category_repository_impl.dart';
import '../../../features/wallet/domain/usecases/get_wallet_summary_usecase.dart';
import '../features/account/domain/usecase/get_accounts_usecase.dart';
import '../features/wallet/domain/usecases/goals/get_goals_usecase.dart';
import '../features/account/domain/usecase/create_account_usecase.dart';
import '../features/account/domain/usecase/update_account_usecase.dart';
import '../features/account/domain/usecase/delete_account_usecase.dart';
import '../features/wallet/domain/usecases/goals/add_goal_usecase.dart';
import '../../../features/wallet/domain/usecases/get_categories_usecase.dart';
import '../../../features/wallet/domain/usecases/initialize_budget_categories_usecase.dart';
import '../../../features/wallet/domain/usecases/check_wallet_initialization_usecase.dart';

import 'package:spend_io_app/features/account/presentation/viewmodels/account_viewmodel.dart';

class AppProviders {
  AppProviders._();

  static List<SingleChildWidget> get providers => [
        // ==============================================================
        // 1. DATA LAYER (DATASOURCES & REPOSITORIES)
        // ==============================================================
        Provider<AuthLocalDatasource>(
          create: (_) => AuthLocalDatasource(),
        ),

        Provider<AuthRemoteDatasource>(
          create: (_) => AuthRemoteDatasource(),
        ),

        Provider<OnboardingLocalDataSource>(
          create: (_) => OnboardingLocalDataSourceImpl(),
        ),

        Provider<OnboardingRemoteDataSource>(
          create: (_) => OnboardingRemoteDataSource(),
        ),

        Provider<AccountLocalDataSource>(
          create: (_) => AccountLocalDataSourceImpl(),
        ),

        Provider<GoalLocalDataSource>(
          create: (_) => GoalLocalDataSourceImpl(),
        ),

        Provider<BudgetLocalDataSource>(
          create: (_) => BudgetLocalDataSourceImpl(),
        ),

        Provider<AccountRemoteDataSource>(
          create: (_) => AccountRemoteDataSourceImpl(),
        ),

        Provider<GoalRemoteDataSource>(
          create: (_) => GoalRemoteDataSourceImpl(),
        ),

        Provider<ProfileLocalDataSource>(
          create: (_) => ProfileLocalDataSource(),
        ),

        Provider<ProfileRemoteDataSource>(
          create: (_) => ProfileRemoteDataSource(),
        ),

        ProxyProvider3<AccountLocalDataSource, GoalLocalDataSource,
            BudgetLocalDataSource, WalletLocalDataSource>(
          update: (_, accountLocal, goalLocal, budgetLocal, __) =>
              WalletLocalDataSourceImpl(
            accountLocal: accountLocal,
            goalLocal: goalLocal,
            budgetLocal: budgetLocal,
          ),
        ),

        Provider<WalletRemoteDataSource>(
          create: (_) => WalletRemoteDataSourceImpl(),
        ),

        ProxyProvider2<AuthLocalDatasource, AuthRemoteDatasource,
            AuthRepositoryImpl>(
          update: (_, local, remote, __) => AuthRepositoryImpl(local, remote),
        ),

        ProxyProvider2<OnboardingLocalDataSource, OnboardingRemoteDataSource,
            OnboardingRepository>(
          update: (_, local, remote, __) => OnboardingRepositoryImpl(
              localDataSource: local, remoteDataSource: remote),
        ),

        ProxyProvider2<WalletLocalDataSource, WalletRemoteDataSource,
            WalletRepositoryImpl>(
          update: (_, local, remote, __) => WalletRepositoryImpl(
              localDataSource: local, remoteDataSource: remote),
        ),

        ProxyProvider2<AccountLocalDataSource, AccountRemoteDataSource,
            AccountRepositoryImpl>(
          update: (_, local, remote, __) => AccountRepositoryImpl(
              localDataSource: local, remoteDataSource: remote),
        ),

        ProxyProvider2<GoalLocalDataSource, GoalRemoteDataSource,
            SavingGoalRepositoryImpl>(
          update: (_, local, remote, __) => SavingGoalRepositoryImpl(
              localDataSource: local, remoteDataSource: remote),
        ),

        ProxyProvider2<ProfileLocalDataSource, ProfileRemoteDataSource,
            ProfileRepositoryImpl>(
          update: (_, local, remote, __) => ProfileRepositoryImpl(
            localDataSource: local,
            remoteDataSource: remote,
          ),
        ),

        ProxyProvider<BudgetLocalDataSource, BudgetCategoryRepositoryImpl>(
          update: (_, local, __) =>
              BudgetCategoryRepositoryImpl(localDataSource: local),
        ),

        // ==============================================================
        // 2. DOMAIN LAYER (USE CASES) - SECURED CONVERGENCE STRUCTURE
        // ==============================================================
        ProxyProvider<AuthRepositoryImpl, CheckEmailUseCase>(
          update: (_, repo, previous) => previous ?? CheckEmailUseCase(repo),
        ),

        ProxyProvider<AuthRepositoryImpl, GetCurrentUserUseCase>(
          update: (_, repo, previous) =>
              previous ?? GetCurrentUserUseCase(repo),
        ),

        ProxyProvider<OnboardingRepository, SaveOnboardingUseCase>(
          update: (_, repo, previous) =>
              previous ?? SaveOnboardingUseCase(repository: repo),
        ),
        ProxyProvider<OnboardingRepository, GetOnboardingUseCase>(
          update: (_, repo, previous) =>
              previous ?? GetOnboardingUseCase(repository: repo),
        ),
        ProxyProvider<OnboardingRepository, CheckOnboardingUseCase>(
          update: (_, repo, previous) =>
              previous ?? CheckOnboardingUseCase(repository: repo),
        ),
        ProxyProvider<OnboardingRepository, CompleteOnboardingUseCase>(
          update: (_, repo, previous) =>
              previous ?? CompleteOnboardingUseCase(repository: repo),
        ),

        ProxyProvider<WalletRepositoryImpl, GetWalletSummaryUseCase>(
          update: (_, repo, previous) =>
              previous ?? GetWalletSummaryUseCase(repo),
        ),
        ProxyProvider<AccountRepositoryImpl, GetAccountsUseCase>(
          update: (_, repo, previous) => previous ?? GetAccountsUseCase(repo),
        ),
        ProxyProvider<SavingGoalRepositoryImpl, GetGoalsUseCase>(
          update: (_, repo, previous) => previous ?? GetGoalsUseCase(repo),
        ),
        ProxyProvider<AccountRepositoryImpl, CreateAccountUseCase>(
          update: (_, repo, previous) => previous ?? CreateAccountUseCase(repo),
        ),
        ProxyProvider<AccountRepositoryImpl, UpdateAccountUseCase>(
          update: (_, repo, previous) => previous ?? UpdateAccountUseCase(repo),
        ),
        ProxyProvider<AccountRepositoryImpl, DeleteAccountUseCase>(
          update: (_, repo, previous) => previous ?? DeleteAccountUseCase(repo),
        ),
        ProxyProvider<SavingGoalRepositoryImpl, AddGoalUseCase>(
          update: (_, repo, previous) => previous ?? AddGoalUseCase(repo),
        ),
        ProxyProvider<BudgetCategoryRepositoryImpl, GetCategoriesUseCase>(
          update: (_, repo, previous) => previous ?? GetCategoriesUseCase(repo),
        ),
        ProxyProvider<BudgetCategoryRepositoryImpl,
            InitializeBudgetCategoriesUseCase>(
          update: (_, repo, previous) =>
              previous ?? InitializeBudgetCategoriesUseCase(repo),
        ),

        ProxyProvider<WalletRepositoryImpl, CheckWalletInitializationUseCase>(
          update: (_, repo, previous) =>
              previous ?? CheckWalletInitializationUseCase(repo),
        ),

        // ==============================================================
        // 3. PRESENTATION LAYER (VIEWMODELS & PROVIDERS)
        // ==============================================================
        ChangeNotifierProxyProvider<CheckEmailUseCase, RegisterFormViewModel>(
          create: (context) => RegisterFormViewModel(
            checkEmailUseCase: context.read<CheckEmailUseCase>(),
          ),
          update: (_, useCase, vm) =>
              vm ?? RegisterFormViewModel(checkEmailUseCase: useCase),
        ),

        ChangeNotifierProvider(
          create: (_) => LoginFormViewModel(),
        ),

        ChangeNotifierProxyProvider4<
            SaveOnboardingUseCase,
            GetOnboardingUseCase,
            CheckOnboardingUseCase,
            CompleteOnboardingUseCase,
            OnboardingViewModel>(
          create: (context) => OnboardingViewModel(
            saveOnboardingUseCase: context.read<SaveOnboardingUseCase>(),
            getOnboardingUseCase: context.read<GetOnboardingUseCase>(),
            checkOnboardingUseCase: context.read<CheckOnboardingUseCase>(),
            completeOnboardingUseCase:
                context.read<CompleteOnboardingUseCase>(),
          ),
          update: (_, saveUC, getUC, checkUC, completeUC, vm) =>
              vm ??
              OnboardingViewModel(
                saveOnboardingUseCase: saveUC,
                getOnboardingUseCase: getUC,
                checkOnboardingUseCase: checkUC,
                completeOnboardingUseCase: completeUC,
              ),
        ),

        ChangeNotifierProxyProvider<AuthRepositoryImpl, AuthProvider>(
          create: (context) => AuthProvider(
            repository: context.read<AuthRepositoryImpl>(),
          ),
          update: (_, repo, provider) =>
              provider ?? AuthProvider(repository: repo),
        ),

        // Startup Coordinator
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

        // 🔥 ACCOUNT VIEWMODEL INJECTOR LOCKED DOWN FOR PHASE 02
        ChangeNotifierProxyProvider<AuthProvider, AccountViewModel>(
          create: (context) => AccountViewModel(
            getAccountsUseCase: context.read<GetAccountsUseCase>(),
            createAccountUseCase: context.read<CreateAccountUseCase>(),
            updateAccountUseCase: context.read<UpdateAccountUseCase>(),
            deleteAccountUseCase: context.read<DeleteAccountUseCase>(),
          ),
          update: (context, authProvider, vm) {
            final activeVm = vm ??
                AccountViewModel(
                  getAccountsUseCase: context.read<GetAccountsUseCase>(),
                  createAccountUseCase: context.read<CreateAccountUseCase>(),
                  updateAccountUseCase: context.read<UpdateAccountUseCase>(),
                  deleteAccountUseCase: context.read<DeleteAccountUseCase>(),
                );

            final userEntity = authProvider.currentUser?.toEntity();

            if (userEntity != null) {
              final localId = userEntity.id ?? 0;
              final String remoteUid =
                  fb_auth.FirebaseAuth.instance.currentUser?.uid ?? '';

              if (localId > 0 &&
                  remoteUid.isNotEmpty &&
                  userEntity.onboardingCompleted == true) {
                activeVm.loadAccounts(localId, remoteUid);
              }
            } else {
              activeVm.clearAccounts();
            }
            return activeVm;
          },
        ),

        ChangeNotifierProxyProvider<AuthProvider, WalletViewModel>(
          create: (context) => WalletViewModel(
            getWalletSummaryUseCase: context.read<GetWalletSummaryUseCase>(),
            getGoalsUseCase: context.read<GetGoalsUseCase>(),
            addGoalUseCase: context.read<AddGoalUseCase>(),
            getCategoriesUseCase: context.read<GetCategoriesUseCase>(),
            initializeBudgetCategoriesUseCase:
                context.read<InitializeBudgetCategoriesUseCase>(),
          ),
          update: (context, authProvider, vm) {
            final activeVm = vm ??
                WalletViewModel(
                  getWalletSummaryUseCase:
                      context.read<GetWalletSummaryUseCase>(),
                  getGoalsUseCase: context.read<GetGoalsUseCase>(),
                  addGoalUseCase: context.read<AddGoalUseCase>(),
                  getCategoriesUseCase: context.read<GetCategoriesUseCase>(),
                  initializeBudgetCategoriesUseCase:
                      context.read<InitializeBudgetCategoriesUseCase>(),
                );
            activeVm.updateUser(authProvider.currentUser?.toEntity());
            return activeVm;
          },
        ),

        ChangeNotifierProxyProvider<WalletViewModel, DashboardViewModel>(
          create: (context) => DashboardViewModel(
            walletViewModel: context.read<WalletViewModel>(),
          ),
          update: (_, walletVM, vm) =>
              vm ?? DashboardViewModel(walletViewModel: walletVM),
        ),

        ChangeNotifierProxyProvider<ProfileRepositoryImpl, ProfileViewModel>(
          create: (context) => ProfileViewModel(
            profileRepository: context.read<ProfileRepositoryImpl>(),
          ),
          update: (_, repo, vm) =>
              vm ?? ProfileViewModel(profileRepository: repo),
        ),
      ];
}

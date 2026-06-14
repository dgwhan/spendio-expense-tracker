import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:spend_io_app/features/wallet/data/datasources/wallet_remote_data_source.dart';
import 'package:spend_io_app/features/wallet/presentation/viewmodels/wallet_viewmodel.dart';
import '../../../features/home/presentation/viewmodels/dashboard_viewmodel.dart';

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
import '../features/wallet/data/datasources/account/account_local_data_source.dart';
import '../features/wallet/data/datasources/account/account_remote_data_source.dart';
import '../features/wallet/data/datasources/goal/goal_local_data_source.dart';
import '../features/wallet/data/datasources/goal/goal_remote_data_source.dart';
import '../features/wallet/data/datasources/budget/budget_local_data_source.dart';
import '../../../features/wallet/data/repositories/wallet_repository_impl.dart';
import '../../../features/wallet/data/repositories/account_repository_impl.dart';
import '../../../features/wallet/data/repositories/saving_goal_repository_impl.dart';
import '../../../features/wallet/data/repositories/budget_category_repository_impl.dart';
import '../../../features/wallet/domain/usecases/get_wallet_summary_usecase.dart';
import '../features/wallet/domain/usecases/accounts/get_accounts_usecase.dart';
import '../features/wallet/domain/usecases/goals/get_goals_usecase.dart';
import '../features/wallet/domain/usecases/accounts/create_account_usecase.dart';
import '../features/wallet/domain/usecases/accounts/update_account_usecase.dart';
import '../features/wallet/domain/usecases/accounts/delete_account_usecase.dart';
import '../features/wallet/domain/usecases/accounts/restore_account_usecase.dart';
import '../features/wallet/domain/usecases/goals/add_goal_usecase.dart';
import '../../../features/wallet/domain/usecases/get_categories_usecase.dart';
import '../../../features/wallet/domain/usecases/initialize_budget_categories_usecase.dart';
import '../../../features/wallet/domain/usecases/check_wallet_initialization_usecase.dart';

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

        // Wallet sub-datasources (local)
        Provider<AccountLocalDataSource>(
          create: (_) => AccountLocalDataSourceImpl(),
        ),

        Provider<GoalLocalDataSource>(
          create: (_) => GoalLocalDataSourceImpl(),
        ),

        Provider<BudgetLocalDataSource>(
          create: (_) => BudgetLocalDataSourceImpl(),
        ),

        // Wallet sub-datasources (remote)
        Provider<AccountRemoteDataSource>(
          create: (_) => AccountRemoteDataSourceImpl(),
        ),

        Provider<GoalRemoteDataSource>(
          create: (_) => GoalRemoteDataSourceImpl(),
        ),

        // Wallet facade datasources
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
            OnboardingRepositoryImpl>(
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

        ProxyProvider<BudgetLocalDataSource, BudgetCategoryRepositoryImpl>(
          update: (_, local, __) => BudgetCategoryRepositoryImpl(
              localDataSource: local),
        ),

        // ==============================================================
        // 2. DOMAIN LAYER (USE CASES)
        // ==============================================================
        ProxyProvider<AuthRepositoryImpl, CheckEmailUseCase>(
          update: (_, repo, __) => CheckEmailUseCase(repo),
        ),

        ProxyProvider<AuthRepositoryImpl, GetCurrentUserUseCase>(
          update: (_, repo, __) => GetCurrentUserUseCase(repo),
        ),

        ProxyProvider<OnboardingRepositoryImpl, SaveOnboardingUseCase>(
          update: (_, repo, __) => SaveOnboardingUseCase(repository: repo),
        ),
        ProxyProvider<OnboardingRepositoryImpl, GetOnboardingUseCase>(
          update: (_, repo, __) => GetOnboardingUseCase(repository: repo),
        ),
        ProxyProvider<OnboardingRepositoryImpl, CheckOnboardingUseCase>(
          update: (_, repo, __) => CheckOnboardingUseCase(repository: repo),
        ),
        ProxyProvider<OnboardingRepositoryImpl, CompleteOnboardingUseCase>(
          update: (_, repo, __) => CompleteOnboardingUseCase(repository: repo),
        ),

        ProxyProvider<WalletRepositoryImpl, GetWalletSummaryUseCase>(
          update: (_, repo, __) => GetWalletSummaryUseCase(repo),
        ),
        ProxyProvider<AccountRepositoryImpl, GetAccountsUseCase>(
          update: (_, repo, __) => GetAccountsUseCase(repo),
        ),
        ProxyProvider<SavingGoalRepositoryImpl, GetGoalsUseCase>(
          update: (_, repo, __) => GetGoalsUseCase(repo),
        ),
        ProxyProvider<AccountRepositoryImpl, CreateAccountUseCase>(
          update: (_, repo, __) => CreateAccountUseCase(repo),
        ),
        ProxyProvider<AccountRepositoryImpl, UpdateAccountUseCase>(
          update: (_, repo, __) => UpdateAccountUseCase(repo),
        ),
        ProxyProvider<AccountRepositoryImpl, DeleteAccountUseCase>(
          update: (_, repo, __) => DeleteAccountUseCase(repo),
        ),
        ProxyProvider<AccountRepositoryImpl, RestoreAccountUseCase>(
          update: (_, repo, __) => RestoreAccountUseCase(repo),
        ),
        ProxyProvider<SavingGoalRepositoryImpl, AddGoalUseCase>(
          update: (_, repo, __) => AddGoalUseCase(repo),
        ),
        ProxyProvider<BudgetCategoryRepositoryImpl, GetCategoriesUseCase>(
          update: (_, repo, __) => GetCategoriesUseCase(repo),
        ),
        ProxyProvider<BudgetCategoryRepositoryImpl, InitializeBudgetCategoriesUseCase>(
          update: (_, repo, __) => InitializeBudgetCategoriesUseCase(repo),
        ),

        ProxyProvider<WalletRepositoryImpl, CheckWalletInitializationUseCase>(
          update: (_, repo, __) => CheckWalletInitializationUseCase(repo),
        ),

        // ==============================================================
        // 3. PRESENTATION LAYER (VIEWMODELS & PROVIDERS)
        // ==============================================================

        // Register VM
        ChangeNotifierProxyProvider<CheckEmailUseCase, RegisterFormViewModel>(
          create: (context) => RegisterFormViewModel(
            checkEmailUseCase: context.read<CheckEmailUseCase>(),
          ),
          update: (_, useCase, vm) =>
              vm ?? RegisterFormViewModel(checkEmailUseCase: useCase),
        ),

        // Login VM
        ChangeNotifierProvider(
          create: (_) => LoginFormViewModel(),
        ),

        // Onboarding VM
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

        // Auth Action Provider
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
          update: (context, authProvider, checkWalletInit, __) =>
              StartupCoordinator(
            authProvider: authProvider,
            checkWalletInitializationUseCase: checkWalletInit,
            getCurrentUserUseCase: context.read<GetCurrentUserUseCase>(),
          ),
        ),

        // Wallet VM
        ChangeNotifierProxyProvider<AuthProvider, WalletViewModel>(
          create: (context) => WalletViewModel(
            getWalletSummaryUseCase: context.read<GetWalletSummaryUseCase>(),
            getAccountsUseCase: context.read<GetAccountsUseCase>(),
            getGoalsUseCase: context.read<GetGoalsUseCase>(),
            createAccountUseCase: context.read<CreateAccountUseCase>(),
            updateAccountUseCase: context.read<UpdateAccountUseCase>(),
            deleteAccountUseCase: context.read<DeleteAccountUseCase>(),
            restoreAccountUseCase: context.read<RestoreAccountUseCase>(),
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
                  getAccountsUseCase: context.read<GetAccountsUseCase>(),
                  getGoalsUseCase: context.read<GetGoalsUseCase>(),
                  createAccountUseCase: context.read<CreateAccountUseCase>(),
                  updateAccountUseCase: context.read<UpdateAccountUseCase>(),
                  deleteAccountUseCase: context.read<DeleteAccountUseCase>(),
                  restoreAccountUseCase: context.read<RestoreAccountUseCase>(),
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
      ];
}

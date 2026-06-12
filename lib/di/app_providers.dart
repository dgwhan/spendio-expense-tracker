import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:spend_io_app/features/wallet/presentation/viewmodels/wallet_viewmodel.dart';
import '../../../features/auth/domain/usecases/check_wallet_usecase.dart';

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
import '../../../features/auth/presentation/viewmodels/register_form_viewmodel.dart';
import '../../../features/auth/presentation/viewmodels/login_form_viewmodel.dart';
import '../../../features/auth/presentation/providers/auth_provider.dart';

// WALLET LAYER
import '../../../features/wallet/data/datasource/wallet_local_data_source.dart';
import '../../../features/wallet/data/datasource/wallet_remote_data_source.dart';
import '../../../features/wallet/data/repositories/wallet_repository_impl.dart';
import '../../../features/wallet/domain/usecases/get_wallet_summary_usecase.dart';
import '../../../features/wallet/domain/usecases/get_accounts_usecase.dart';
import '../../../features/wallet/domain/usecases/get_goals_usecase.dart';
import '../../../features/wallet/domain/usecases/add_account_usecase.dart';
import '../../../features/wallet/domain/usecases/add_goal_usecase.dart';

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

        Provider<WalletLocalDataSource>(
          create: (_) => WalletLocalDataSourceImpl(),
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

        // ==============================================================
        // 2. DOMAIN LAYER (USE CASES)
        // ==============================================================
        ProxyProvider<AuthRepositoryImpl, CheckEmailUseCase>(
          update: (_, repo, __) => CheckEmailUseCase(repo),
        ),

        ProxyProvider<AuthRepositoryImpl, CheckWalletUseCase>(
          update: (_, repo, __) => CheckWalletUseCase(repo),
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
        ProxyProvider<WalletRepositoryImpl, GetAccountsUseCase>(
          update: (_, repo, __) => GetAccountsUseCase(repo),
        ),
        ProxyProvider<WalletRepositoryImpl, GetGoalsUseCase>(
          update: (_, repo, __) => GetGoalsUseCase(repo),
        ),
        ProxyProvider<WalletRepositoryImpl, AddAccountUseCase>(
          update: (_, repo, __) => AddAccountUseCase(repo),
        ),
        ProxyProvider<WalletRepositoryImpl, AddGoalUseCase>(
          update: (_, repo, __) => AddGoalUseCase(repo),
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

        // Wallet VM
        ChangeNotifierProxyProvider<AuthProvider, WalletViewModel>(
          create: (context) => WalletViewModel(
            getWalletSummaryUseCase: context.read<GetWalletSummaryUseCase>(),
            getAccountsUseCase: context.read<GetAccountsUseCase>(),
            getGoalsUseCase: context.read<GetGoalsUseCase>(),
            addAccountUseCase: context.read<AddAccountUseCase>(),
            addGoalUseCase: context.read<AddGoalUseCase>(),
          ),
          update: (context, authProvider, vm) {
            final activeVm = vm ??
                WalletViewModel(
                  getWalletSummaryUseCase:
                      context.read<GetWalletSummaryUseCase>(),
                  getAccountsUseCase: context.read<GetAccountsUseCase>(),
                  getGoalsUseCase: context.read<GetGoalsUseCase>(),
                  addAccountUseCase: context.read<AddAccountUseCase>(),
                  addGoalUseCase: context.read<AddGoalUseCase>(),
                );
            activeVm.updateUser(authProvider.currentUser);
            return activeVm;
          },
        ),
      ];
}

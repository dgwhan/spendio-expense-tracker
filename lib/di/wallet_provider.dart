import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

// DATA LAYER
import 'package:spend_io_app/features/wallet/data/datasources/wallet_local_data_source.dart';
import 'package:spend_io_app/features/wallet/data/datasources/wallet_remote_data_source.dart';
import 'package:spend_io_app/features/account/data/datasource/account_local_data_source.dart';
import 'package:spend_io_app/features/wallet/data/datasources/goal/goal_local_data_source.dart';
import 'package:spend_io_app/features/wallet/data/datasources/goal/goal_remote_data_source.dart';
import 'package:spend_io_app/features/wallet/data/datasources/budget/budget_local_data_source.dart';
import 'package:spend_io_app/features/wallet/data/repositories/wallet_repository_impl.dart';
import 'package:spend_io_app/features/wallet/data/repositories/saving_goal_repository_impl.dart';
import 'package:spend_io_app/features/wallet/data/repositories/budget_category_repository_impl.dart';
import 'package:spend_io_app/features/wallet/domain/repositories/wallet_repository.dart';

// DOMAIN LAYER
import 'package:spend_io_app/features/wallet/domain/usecases/get_wallet_summary_usecase.dart';
import 'package:spend_io_app/features/wallet/domain/usecases/goals/get_goals_usecase.dart';
import 'package:spend_io_app/features/wallet/domain/usecases/goals/add_goal_usecase.dart';
import 'package:spend_io_app/features/wallet/domain/usecases/get_categories_usecase.dart';
import 'package:spend_io_app/features/wallet/domain/usecases/initialize_budget_categories_usecase.dart';
import 'package:spend_io_app/features/wallet/domain/usecases/check_wallet_initialization_usecase.dart';

// PRESENTATION LAYER
import 'package:spend_io_app/features/wallet/presentation/viewmodels/wallet_viewmodel.dart';
import 'package:spend_io_app/features/home/presentation/viewmodels/dashboard_viewmodel.dart';
import 'package:spend_io_app/features/auth/presentation/providers/auth_provider.dart';

class WalletModuleProvider {
  WalletModuleProvider._();

  static List<SingleChildWidget> get providers => [
        // 1. DATA LAYER
        Provider<GoalLocalDataSource>(create: (_) => GoalLocalDataSourceImpl()),
        Provider<BudgetLocalDataSource>(
            create: (_) => BudgetLocalDataSourceImpl()),
        Provider<GoalRemoteDataSource>(
            create: (_) => GoalRemoteDataSourceImpl()),
        Provider<WalletRemoteDataSource>(
            create: (_) => WalletRemoteDataSourceImpl()),

        ProxyProvider3<AccountLocalDataSource, GoalLocalDataSource,
            BudgetLocalDataSource, WalletLocalDataSource>(
          update: (context, accountLocal, goalLocal, budgetLocal, __) =>
              WalletLocalDataSourceImpl(
            accountLocal: accountLocal,
            goalLocal: goalLocal,
            budgetLocal: budgetLocal,
          ),
        ),

        ProxyProvider2<WalletLocalDataSource, WalletRemoteDataSource,
            WalletRepositoryImpl>(
          update: (_, local, remote, __) => WalletRepositoryImpl(
              localDataSource: local, remoteDataSource: remote),
        ),
        ProxyProvider2<GoalLocalDataSource, GoalRemoteDataSource,
            SavingGoalRepositoryImpl>(
          update: (_, local, remote, __) => SavingGoalRepositoryImpl(
              localDataSource: local, remoteDataSource: remote),
        ),

        ProxyProvider<WalletRepositoryImpl, WalletRepository>(
          update: (_, impl, __) => impl,
        ),
        ProxyProvider<BudgetLocalDataSource, BudgetCategoryRepositoryImpl>(
          update: (_, local, __) =>
              BudgetCategoryRepositoryImpl(localDataSource: local),
        ),

        // 2. DOMAIN LAYER
        ProxyProvider<WalletRepositoryImpl, GetWalletSummaryUseCase>(
          update: (_, repo, previous) =>
              previous ?? GetWalletSummaryUseCase(repo),
        ),
        ProxyProvider<SavingGoalRepositoryImpl, GetGoalsUseCase>(
          update: (_, repo, previous) => previous ?? GetGoalsUseCase(repo),
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

        // 3. PRESENTATION LAYER
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
              walletViewModel: context.read<WalletViewModel>()),
          update: (_, walletVM, vm) =>
              vm ?? DashboardViewModel(walletViewModel: walletVM),
        ),
      ];
}

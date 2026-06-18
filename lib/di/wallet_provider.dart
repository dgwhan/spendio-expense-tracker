import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:spend_io_app/features/budget/data/datasources/budget_local_data_source.dart';
import 'package:spend_io_app/features/wallet/data/datasources/wallet_local_data_source.dart';
import 'package:spend_io_app/features/wallet/data/datasources/wallet_remote_data_source.dart';
import 'package:spend_io_app/features/account/data/datasource/account_local_data_source.dart';
import 'package:spend_io_app/features/wallet/data/datasources/goal/goal_local_data_source.dart';
import 'package:spend_io_app/features/wallet/data/datasources/goal/goal_remote_data_source.dart';
import 'package:spend_io_app/features/wallet/data/repositories/wallet_repository_impl.dart';
import 'package:spend_io_app/features/wallet/data/repositories/saving_goal_repository_impl.dart';
import 'package:spend_io_app/features/wallet/domain/repositories/wallet_repository.dart';
import 'package:spend_io_app/features/wallet/domain/usecases/get_wallet_summary_usecase.dart';
import 'package:spend_io_app/features/wallet/domain/usecases/goals/get_goals_usecase.dart';
import 'package:spend_io_app/features/wallet/domain/usecases/goals/add_goal_usecase.dart';
import 'package:spend_io_app/features/wallet/domain/usecases/check_wallet_initialization_usecase.dart';
import 'package:spend_io_app/features/budget/domain/repositories/budget_repository.dart';
import 'package:spend_io_app/features/budget/domain/services/budget_progress_calculator.dart';
import 'package:spend_io_app/features/wallet/presentation/viewmodels/wallet_viewmodel.dart';
import 'package:spend_io_app/features/home/presentation/viewmodels/dashboard_viewmodel.dart';
import 'package:spend_io_app/features/auth/presentation/providers/auth_provider.dart';

class WalletModuleProvider {
  WalletModuleProvider._();

  static List<SingleChildWidget> get providers => [
        // =========================================================
        // 1. DATA LAYER
        // =========================================================
        Provider<GoalLocalDataSource>(create: (_) => GoalLocalDataSourceImpl()),
        Provider<GoalRemoteDataSource>(
            create: (_) => GoalRemoteDataSourceImpl()),
        Provider<WalletRemoteDataSource>(
            create: (_) => WalletRemoteDataSourceImpl()),

        ProxyProvider3<AccountLocalDataSource, GoalLocalDataSource,
            BudgetLocalDataSource, WalletLocalDataSource>(
          update: (context, accountLocal, goalLocal, budgetLocal, __) {
            return WalletLocalDataSourceImpl(
              accountLocal: accountLocal,
              goalLocal: goalLocal,
              budgetLocal: budgetLocal,
            );
          },
        ),

        ProxyProvider2<WalletLocalDataSource, WalletRemoteDataSource,
            WalletRepositoryImpl>(
          update: (_, local, remote, __) => WalletRepositoryImpl(
            localDataSource: local,
            remoteDataSource: remote,
          ),
        ),

        ProxyProvider2<GoalLocalDataSource, GoalRemoteDataSource,
            SavingGoalRepositoryImpl>(
          update: (_, local, remote, __) => SavingGoalRepositoryImpl(
            localDataSource: local,
            remoteDataSource: remote,
          ),
        ),

        ProxyProvider<WalletRepositoryImpl, WalletRepository>(
          update: (_, impl, __) => impl,
        ),

        // =========================================================
        // 2. DOMAIN LAYER
        // =========================================================
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
        ProxyProvider<WalletRepositoryImpl, CheckWalletInitializationUseCase>(
          update: (_, repo, previous) =>
              previous ?? CheckWalletInitializationUseCase(repo),
        ),

        // =========================================================
        // 3. PRESENTATION LAYER (CẬP NHẬT ĐOẠN ĐUÔI FILE CỦA BÀ)
        // =========================================================
        ChangeNotifierProxyProvider<AuthProvider, WalletViewModel>(
          create: (context) => WalletViewModel(
            getWalletSummaryUseCase: context.read<GetWalletSummaryUseCase>(),
            getGoalsUseCase: context.read<GetGoalsUseCase>(),
            addGoalUseCase: context.read<AddGoalUseCase>(),
            budgetRepository: context.read<BudgetRepository>(),
            budgetCalculator: context.read<BudgetProgressCalculator>(),
          ),
          update: (context, authProvider, previousViewModel) {
            final vm = previousViewModel!;
            final newUser = authProvider.currentUser?.toEntity();

            if (vm.currentUser?.id != newUser?.id ||
                vm.currentUser?.email != newUser?.email) {
              debugPrint(
                  '[PROVIDER LOG]: AuthProvider đổi user -> Đẩy sang WalletViewModel');
              vm.updateUser(newUser);
            }
            return vm;
          },
        ),

        ChangeNotifierProxyProvider<WalletViewModel, DashboardViewModel>(
          create: (context) => DashboardViewModel(
            walletViewModel: context.read<WalletViewModel>(),
          ),
          update: (context, walletVM, previousDashboardVM) {
            final dashboardVM = previousDashboardVM!;
            debugPrint(
                '[PROVIDER LOG]: Luồng Proxy gán Wallet sang DashboardViewModel.');
            dashboardVM.updateWallet(walletVM);
            return dashboardVM;
          },
        ),
      ];
}

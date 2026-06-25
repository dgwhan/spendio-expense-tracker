import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:spend_io_app/features/account/domain/repositories/account_repository.dart';
import 'package:spend_io_app/features/budget/domain/repositories/budget_repository.dart';
import 'package:spend_io_app/features/saving_goal/domain/repositories/saving_goal_repository.dart';
import 'package:spend_io_app/features/wallet/data/repositories/wallet_repository_impl.dart';
import 'package:spend_io_app/features/wallet/domain/repositories/wallet_repository.dart';
import 'package:spend_io_app/features/wallet/domain/usecases/get_wallet_summary_usecase.dart';
import 'package:spend_io_app/features/wallet/domain/usecases/check_wallet_initialization_usecase.dart';
import 'package:spend_io_app/features/wallet/presentation/viewmodels/wallet_viewmodel.dart';
import 'package:spend_io_app/features/home/presentation/viewmodels/home_viewmodel.dart';
import 'package:spend_io_app/features/auth/presentation/providers/auth_provider.dart';

class WalletModuleProvider {
  WalletModuleProvider._();

  static List<SingleChildWidget> get providers => [
        //WALLET REPOSITORY
        ProxyProvider3<AccountRepository, SavingGoalRepository,
            BudgetRepository, WalletRepository>(
          update: (
            context,
            accountRepo,
            goalRepo,
            budgetRepo,
            previous,
          ) {
            return WalletRepositoryImpl(
              accountRepository: accountRepo,
              goalRepository: goalRepo,
              budgetRepository: budgetRepo,
            );
          },
        ),
        //USECASE
        ProxyProvider<WalletRepository, GetWalletSummaryUseCase>(
          update: (context, repo, previous) {
            return GetWalletSummaryUseCase(repo);
          },
        ),

        ProxyProvider<WalletRepository, CheckWalletInitializationUseCase>(
          update: (context, repo, previous) {
            return CheckWalletInitializationUseCase(repo);
          },
        ),
        //VIEWMODELS
        ChangeNotifierProxyProvider<AuthProvider, WalletViewModel>(
          create: (context) => WalletViewModel(
            getWalletSummaryUseCase: context.read<GetWalletSummaryUseCase>(),
          ),
          update: (context, authProvider, previous) {
            final vm = previous!;
            vm.updateUser(authProvider.currentUser?.toEntity());
            return vm;
          },
        ),

        ChangeNotifierProxyProvider<WalletViewModel, HomeViewModel>(
          create: (context) => HomeViewModel(
            walletViewModel: context.read<WalletViewModel>(),
          ),
          update: (context, walletVM, previous) {
            final vm = previous!;
            vm.updateWallet(walletVM);
            return vm;
          },
        ),
      ];
}

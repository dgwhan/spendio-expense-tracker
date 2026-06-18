import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

// ================= DATA =================
import 'package:spend_io_app/features/budget/data/datasources/budget_local_data_source.dart';
import 'package:spend_io_app/features/budget/data/datasources/budget_remote_data_source.dart';
import 'package:spend_io_app/features/budget/data/repositories/budget_repository_impl.dart';

// ================= DOMAIN =================
import 'package:spend_io_app/features/budget/domain/repositories/budget_repository.dart';
import 'package:spend_io_app/features/budget/domain/services/budget_progress_calculator.dart';

// ================= APPLICATION =================
import 'package:spend_io_app/features/budget/application/budget_progress_calculator_impl.dart';

// ================= PRESENTATION =================
import 'package:spend_io_app/features/budget/presentation/viewmodels/budget_viewmodel.dart';
import 'package:spend_io_app/features/budget/presentation/viewmodels/budget_category_viewmodel.dart';
import 'package:spend_io_app/features/budget/presentation/viewmodels/budget_form_viewmodel.dart';
import 'package:spend_io_app/features/budget/presentation/viewmodels/budget_category_form_viewmodel.dart';

// ================= OTHER FEATURES =================
import 'package:spend_io_app/features/transaction/domain/repositories/transaction_repository.dart';

class BudgetModuleProvider {
  BudgetModuleProvider._();

  static List<SingleChildWidget> get providers => [
        // =========================================================
        // 1. DATA SOURCES
        // =========================================================
        Provider<BudgetLocalDataSource>(
          create: (_) => BudgetLocalDataSourceImpl(),
        ),

        Provider<BudgetRemoteDataSource>(
          create: (_) => BudgetRemoteDataSourceImpl(),
        ),

        // =========================================================
        // 2. REPOSITORY LAYER
        // =========================================================
        ProxyProvider2<BudgetLocalDataSource, BudgetRemoteDataSource,
            BudgetRepository>(
          update: (_, local, remote, __) => BudgetRepositoryImpl(
            localDataSource: local,
            remoteDataSource: remote,
          ),
        ),

        // =========================================================
        // 3. APPLICATION SERVICE (Business Logic Engine)
        // =========================================================
        ProxyProvider2<BudgetRepository, TransactionRepository,
            BudgetProgressCalculator>(
          update: (_, budgetRepo, transactionRepo, __) =>
              BudgetProgressCalculatorImpl(
            budgetRepository: budgetRepo,
            transactionRepository: transactionRepo,
          ),
        ),

        // =========================================================
        // 4. VIEWMODELS
        // =========================================================
        ChangeNotifierProxyProvider2<BudgetRepository, BudgetProgressCalculator,
            BudgetViewModel>(
          create: (context) => BudgetViewModel(
            repository: context.read<BudgetRepository>(),
            calculator: context.read<BudgetProgressCalculator>(),
          ),
          update: (context, repo, calc, previous) {
            if (previous == null) {
              return BudgetViewModel(repository: repo, calculator: calc);
            }
            return previous;
          },
        ),

        ChangeNotifierProxyProvider2<BudgetRepository, BudgetProgressCalculator,
            BudgetCategoryViewModel>(
          create: (context) => BudgetCategoryViewModel(
            repository: context.read<BudgetRepository>(),
            calculator: context.read<BudgetProgressCalculator>(),
          ),
          update: (context, repo, calc, previous) {
            if (previous == null) {
              return BudgetCategoryViewModel(
                  repository: repo, calculator: calc);
            }
            return previous;
          },
        ),

        // =========================================================
        // 5. FORM VIEWMODELS
        // =========================================================
        ChangeNotifierProvider(
          create: (_) => BudgetFormViewModel(),
        ),

        ChangeNotifierProvider(
          create: (_) => BudgetCategoryFormViewModel(),
        ),
      ];
}

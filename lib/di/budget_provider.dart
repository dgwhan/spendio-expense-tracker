import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:spend_io_app/features/transaction/domain/repositories/transaction_repository.dart';
import 'package:sqflite/sqflite.dart';

import 'package:spend_io_app/features/budget/data/datasources/budget_local_data_source.dart';
import 'package:spend_io_app/features/budget/data/datasources/budget_remote_data_source.dart';
import 'package:spend_io_app/features/budget/data/repositories/budget_repository_impl.dart';
import 'package:spend_io_app/features/budget/domain/repositories/budget_repository.dart';
import 'package:spend_io_app/features/budget/domain/services/budget_progress_calculator.dart';
import 'package:spend_io_app/features/budget/application/budget_progress_calculator_impl.dart';

import 'package:spend_io_app/features/budget/presentation/viewmodels/budget_viewmodel.dart';
import 'package:spend_io_app/features/budget/presentation/viewmodels/budget_category_viewmodel.dart';

class BudgetModuleProvider {
  BudgetModuleProvider._();

  static List<SingleChildWidget> providers = [
    // =========================
    // DATA SOURCE
    // =========================
    Provider<BudgetLocalDataSource>(
      create: (context) {
        final db = context.read<Database>();
        return BudgetLocalDataSourceImpl(db);
      },
    ),

    Provider<BudgetRemoteDataSource>(
      create: (_) => BudgetRemoteDataSourceImpl(),
    ),

    // =========================
    // REPOSITORY
    // =========================
    ProxyProvider2<BudgetLocalDataSource, BudgetRemoteDataSource,
        BudgetRepository>(
      update: (_, local, remote, __) {
        return BudgetRepositoryImpl(
          localDataSource: local,
          remoteDataSource: remote,
        );
      },
    ),

    // =========================
    // DOMAIN SERVICE
    // =========================
    ProxyProvider2<BudgetRepository, TransactionRepository,
        BudgetProgressCalculator>(
      update: (_, repo, txRepo, __) {
        return BudgetProgressCalculatorImpl(
          budgetRepository: repo,
          transactionRepository: txRepo,
        );
      },
    ),

    // =========================
    // VIEWMODELS
    // =========================
    ChangeNotifierProxyProvider2<BudgetRepository, BudgetProgressCalculator,
        BudgetViewModel>(
      create: (context) => BudgetViewModel(
        repository: context.read<BudgetRepository>(),
        calculator: context.read<BudgetProgressCalculator>(),
      ),
      update: (_, repo, calc, previous) =>
          previous ?? BudgetViewModel(repository: repo, calculator: calc),
    ),

    ChangeNotifierProxyProvider2<BudgetRepository, BudgetProgressCalculator,
        BudgetCategoryViewModel>(
      create: (context) => BudgetCategoryViewModel(
        repository: context.read<BudgetRepository>(),
        calculator: context.read<BudgetProgressCalculator>(),
      ),
      update: (_, repo, calc, previous) =>
          previous ??
          BudgetCategoryViewModel(repository: repo, calculator: calc),
    ),
  ];
}

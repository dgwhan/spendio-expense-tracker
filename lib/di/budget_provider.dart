import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:spend_io_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:spend_io_app/features/budget/domain/usecase/monthly/delete_budget_usecase.dart';
import 'package:spend_io_app/features/budget/domain/usecase/monthly/update_budget_usecase.dart';
import 'package:spend_io_app/features/budget/domain/usecase/category/create_budget_category_usecase.dart';
import 'package:spend_io_app/features/budget/domain/usecase/category/get_budget_categories_usecase.dart';
import 'package:spend_io_app/features/budget/domain/usecase/category/update_budget_category_usecase.dart';
import 'package:spend_io_app/features/budget/domain/usecase/category/delete_budget_category_usecase.dart';
import 'package:spend_io_app/features/transaction/domain/repositories/transaction_repository.dart';
import 'package:sqflite/sqflite.dart';

import 'package:spend_io_app/features/budget/data/datasources/budget_local_data_source.dart';
import 'package:spend_io_app/features/budget/data/datasources/budget_remote_data_source.dart';
import 'package:spend_io_app/features/budget/data/repositories/budget_repository_impl.dart';
import 'package:spend_io_app/features/budget/domain/repositories/budget_repository.dart';
import 'package:spend_io_app/features/budget/domain/services/budget_progress_calculator.dart';
import 'package:spend_io_app/features/budget/application/budget_progress_calculator_impl.dart';

import 'package:spend_io_app/features/budget/presentation/viewmodels/monthly/budget_viewmodel.dart';
import 'package:spend_io_app/features/budget/presentation/viewmodels/category/budget_category_viewmodel.dart';
import 'package:spend_io_app/features/budget/presentation/viewmodels/category/budget_category_form_viewmodel.dart'; // ✅ IMPORT FILE FORM VIEWMODEL MỚI

class BudgetModuleProvider {
  BudgetModuleProvider._();

  static List<SingleChildWidget> providers = [
    //DATA SOURCE
    Provider<BudgetLocalDataSource>(
      create: (context) {
        final db = context.read<Database>();
        return BudgetLocalDataSourceImpl(db);
      },
    ),

    Provider<BudgetRemoteDataSource>(
      create: (_) => BudgetRemoteDataSourceImpl(
        firestore: FirebaseFirestore.instance,
      ),
    ),

    //REPOSITORY
    ProxyProvider2<BudgetLocalDataSource, BudgetRemoteDataSource,
        BudgetRepository>(
      update: (_, local, remote, __) {
        return BudgetRepositoryImpl(
          localDataSource: local,
          remoteDataSource: remote,
        );
      },
    ),

    //MONTHLY BUDGET USE CASES
    ProxyProvider<BudgetRepository, UpdateBudgetUseCase>(
      update: (_, repo, previous) => previous ?? UpdateBudgetUseCase(repo),
    ),

    ProxyProvider<BudgetRepository, DeleteBudgetUseCase>(
      update: (_, repo, previous) => previous ?? DeleteBudgetUseCase(repo),
    ),

    //CATEGORY BUDGET USE CASES
    ProxyProvider<BudgetRepository, CreateBudgetCategoryUseCase>(
      update: (_, repo, previous) =>
          previous ?? CreateBudgetCategoryUseCase(repo),
    ),

    ProxyProvider<BudgetRepository, GetBudgetCategoriesUseCase>(
      update: (_, repo, previous) =>
          previous ?? GetBudgetCategoriesUseCase(repo),
    ),

    ProxyProvider<BudgetRepository, UpdateBudgetCategoryUseCase>(
      update: (_, repo, previous) =>
          previous ?? UpdateBudgetCategoryUseCase(repo),
    ),

    ProxyProvider<BudgetRepository, DeleteBudgetCategoryUseCase>(
      update: (_, repo, previous) =>
          previous ?? DeleteBudgetCategoryUseCase(repo),
    ),

    //DOMAIN SERVICE
    ProxyProvider2<BudgetRepository, TransactionRepository,
        BudgetProgressCalculator>(
      update: (_, repo, txRepo, __) {
        return BudgetProgressCalculatorImpl(
          budgetRepository: repo,
          transactionRepository: txRepo,
        );
      },
    ),

    //VIEWMODELS
    ChangeNotifierProxyProvider3<BudgetRepository, BudgetProgressCalculator,
        AuthProvider, BudgetViewModel>(
      create: (context) => BudgetViewModel(
        repository: context.read<BudgetRepository>(),
        calculator: context.read<BudgetProgressCalculator>(),
      ),
      update: (_, repo, calc, authProvider, previous) {
        final vm = previous ?? BudgetViewModel(repository: repo, calculator: calc);
        if (authProvider.currentUser == null) {
          vm.clear();
        }
        return vm;
      },
    ),

    ChangeNotifierProxyProvider6<
        CreateBudgetCategoryUseCase,
        GetBudgetCategoriesUseCase,
        UpdateBudgetCategoryUseCase,
        DeleteBudgetCategoryUseCase,
        BudgetProgressCalculator,
        AuthProvider,
        BudgetCategoryViewModel>(
      create: (context) => BudgetCategoryViewModel(
        createUseCase: context.read<CreateBudgetCategoryUseCase>(),
        getUseCase: context.read<GetBudgetCategoriesUseCase>(),
        updateUseCase: context.read<UpdateBudgetCategoryUseCase>(),
        deleteUseCase: context.read<DeleteBudgetCategoryUseCase>(),
        calculator: context.read<BudgetProgressCalculator>(),
      ),
      update: (_, create, get, update, delete, calc, authProvider, previous) {
        final vm = previous ??
            BudgetCategoryViewModel(
              createUseCase: create,
              getUseCase: get,
              updateUseCase: update,
              deleteUseCase: delete,
              calculator: calc,
            );
        if (authProvider.currentUser == null) {
          vm.clear();
        }
        return vm;
      },
    ),

    ChangeNotifierProvider<BudgetCategoryFormViewModel>(
      create: (_) => BudgetCategoryFormViewModel(),
    ),
  ];
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:spend_io_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:sqflite/sqflite.dart';

import 'package:spend_io_app/features/saving_goal/data/datasource/saving_goal_local_datasource.dart';
import 'package:spend_io_app/features/saving_goal/data/datasource/saving_goal_remote_datasource.dart';
import 'package:spend_io_app/features/saving_goal/data/repositories/saving_goal_repository_impl.dart';
import 'package:spend_io_app/features/saving_goal/domain/repositories/saving_goal_repository.dart';

import 'package:spend_io_app/features/saving_goal/domain/usecases/add_goal_contribution_usecase.dart';
import 'package:spend_io_app/features/saving_goal/domain/usecases/create_goal_usecase.dart';
import 'package:spend_io_app/features/saving_goal/domain/usecases/delete_goal_usecase.dart';
import 'package:spend_io_app/features/saving_goal/domain/usecases/get_goal_by_id_usecase.dart';
import 'package:spend_io_app/features/saving_goal/domain/usecases/get_goal_contributions_usecase.dart';
import 'package:spend_io_app/features/saving_goal/domain/usecases/get_goals_usecase.dart';
import 'package:spend_io_app/features/saving_goal/domain/usecases/update_goal_usecase.dart';

import 'package:spend_io_app/features/saving_goal/presentation/viewmodels/create_saving_goal_viewmodel.dart';
import 'package:spend_io_app/features/saving_goal/presentation/viewmodels/saving_goal_detail_viewmodel.dart';
import 'package:spend_io_app/features/saving_goal/presentation/viewmodels/saving_goal_list_viewmodel.dart';

class SavingGoalModuleProvider {
  SavingGoalModuleProvider._();

  static List<SingleChildWidget> providers(Database db) {
    return [
      // =====================================================
      // DATA SOURCES
      // =====================================================

      Provider<SavingGoalLocalDatasource>(
        create: (_) => SavingGoalLocalDataSourceImpl(db),
      ),

      Provider<SavingGoalRemoteDataSource>(
        create: (_) => SavingGoalRemoteDataSourceImpl(
          firestore: FirebaseFirestore.instance,
          auth: FirebaseAuth.instance,
        ),
      ),

      // =====================================================
      // REPOSITORY
      // =====================================================

      ProxyProvider2<SavingGoalLocalDatasource, SavingGoalRemoteDataSource,
          SavingGoalRepository>(
        update: (_, local, remote, __) {
          return SavingGoalRepositoryImpl(
            local: local,
            remote: remote,
            db: db,
          );
        },
      ),

      // =====================================================
      // USE CASES
      // =====================================================

      ProxyProvider<SavingGoalRepository, GetGoalsUseCase>(
        update: (_, repo, __) => GetGoalsUseCase(repo),
      ),

      ProxyProvider<SavingGoalRepository, GetGoalByIdUseCase>(
        update: (_, repo, __) => GetGoalByIdUseCase(repo),
      ),

      ProxyProvider<SavingGoalRepository, CreateGoalUseCase>(
        update: (_, repo, __) => CreateGoalUseCase(repo),
      ),

      ProxyProvider<SavingGoalRepository, UpdateGoalUseCase>(
        update: (_, repo, __) => UpdateGoalUseCase(repo),
      ),

      ProxyProvider<SavingGoalRepository, DeleteGoalUseCase>(
        update: (_, repo, __) => DeleteGoalUseCase(repo),
      ),

      ProxyProvider<SavingGoalRepository, AddGoalContributionUseCase>(
        update: (_, repo, __) => AddGoalContributionUseCase(repo),
      ),

      ProxyProvider<SavingGoalRepository, GetGoalContributionsUseCase>(
        update: (_, repo, __) => GetGoalContributionsUseCase(repo),
      ),

      // =====================================================
      // VIEWMODELS
      // =====================================================

      ChangeNotifierProxyProvider2<GetGoalsUseCase, AuthProvider,
          SavingGoalListViewModel>(
        create: (context) => SavingGoalListViewModel(
          getGoalsUseCase: context.read<GetGoalsUseCase>(),
        ),
        update: (_, useCase, authProvider, vm) {
          final activeVm = vm ??
              SavingGoalListViewModel(
                getGoalsUseCase: useCase,
              );
          if (authProvider.currentUser == null) {
            activeVm.clearGoals();
          }
          return activeVm;
        },
      ),

      ChangeNotifierProxyProvider5<
          GetGoalByIdUseCase,
          GetGoalContributionsUseCase,
          AddGoalContributionUseCase,
          UpdateGoalUseCase,
          DeleteGoalUseCase,
          SavingGoalDetailViewModel>(
        create: (context) => SavingGoalDetailViewModel(
          getGoalByIdUseCase: context.read<GetGoalByIdUseCase>(),
          getGoalContributionsUseCase:
              context.read<GetGoalContributionsUseCase>(),
          addGoalContributionUseCase:
              context.read<AddGoalContributionUseCase>(),
          updateGoalUseCase: context.read<UpdateGoalUseCase>(),
          deleteGoalUseCase: context.read<DeleteGoalUseCase>(),
        ),
        update: (
          _,
          getById,
          getContrib,
          addContrib,
          updateGoal,
          deleteGoal,
          vm,
        ) {
          return vm ??
              SavingGoalDetailViewModel(
                getGoalByIdUseCase: getById,
                getGoalContributionsUseCase: getContrib,
                addGoalContributionUseCase: addContrib,
                updateGoalUseCase: updateGoal,
                deleteGoalUseCase: deleteGoal,
              );
        },
      ),

      ChangeNotifierProxyProvider3<CreateGoalUseCase, UpdateGoalUseCase,
          DeleteGoalUseCase, CreateSavingGoalViewModel>(
        create: (context) => CreateSavingGoalViewModel(
          createGoalUseCase: context.read(),
          updateGoalUseCase: context.read(),
          deleteGoalUseCase: context.read(),
        ),
        update: (_, create, update, delete, vm) {
          return vm ??
              CreateSavingGoalViewModel(
                createGoalUseCase: create,
                updateGoalUseCase: update,
                deleteGoalUseCase: delete,
              );
        },
      ),
    ];
  }
}

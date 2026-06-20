import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:sqflite/sqflite.dart';

import 'package:spend_io_app/features/goal/data/datasource/goal_local_datasource.dart';
import 'package:spend_io_app/features/goal/data/repositories/goal_repository_impl.dart';
import 'package:spend_io_app/features/goal/domain/repositories/goal_repository.dart';
import 'package:spend_io_app/features/goal/presentation/viewmodels/goal_list_viewmodel.dart';

class GoalModuleProvider {
  GoalModuleProvider._();

  static List<SingleChildWidget> providers(Database db) => [
        // =========================
        // DATA SOURCE
        // =========================

        Provider<GoalLocalDataSource>(
          create: (_) => GoalLocalDataSourceImpl(db),
        ),

        // =========================
        // REPOSITORY (IMPORTANT FIX)
        // =========================

        ProxyProvider<GoalLocalDataSource, GoalRepository>(
          update: (_, local, __) {
            return GoalRepositoryImpl(
              local: local,
              db: db,
            );
          },
        ),

        // =========================
        // VIEWMODEL
        // =========================

        ChangeNotifierProxyProvider<GoalRepository, GoalListViewModel>(
          create: (context) => GoalListViewModel(
            context.read<GoalRepository>(),
          ),
          update: (context, repo, previous) {
            return GoalListViewModel(repo);
          },
        ),
      ];
}

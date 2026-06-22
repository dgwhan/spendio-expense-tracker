import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:sqflite/sqflite.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:spend_io_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:spend_io_app/features/category/data/datasources/category_local_data_source.dart';
import 'package:spend_io_app/features/category/data/datasources/category_remote_data_source.dart';
import 'package:spend_io_app/features/category/data/repositories/category_repository_impl.dart';
import 'package:spend_io_app/features/category/domain/repositories/category_repository.dart';
import 'package:spend_io_app/features/category/presentation/viewmodels/category_viewmodel.dart';

class CategoryModuleProvider {
  CategoryModuleProvider._();

  static List<SingleChildWidget> get providers => [
        // =========================================================
        // 1. DATA SOURCES
        // =========================================================
        ProxyProvider<Database, CategoryLocalDataSource>(
          update: (_, dbInstance, __) {
            return CategoryLocalDataSourceImpl(database: dbInstance);
          },
        ),

        Provider<CategoryRemoteDataSource>(
          create: (_) => CategoryRemoteDataSourceImpl(
            firestore: FirebaseFirestore.instance,
          ),
        ),

        // =========================================================
        // 3. REPOSITORY LAYER
        // =========================================================
        ProxyProvider2<CategoryLocalDataSource, CategoryRemoteDataSource,
            CategoryRepository>(
          update: (_, localSrc, remoteSrc, __) => CategoryRepositoryImpl(
            localDataSource: localSrc,
            remoteDataSource: remoteSrc,
          ),
        ),

        // =========================================================
        // 4. PRESENTATION LAYER
        // =========================================================
        ChangeNotifierProxyProvider2<CategoryRepository, AuthProvider, CategoryViewModel>(
          create: (context) => CategoryViewModel(
            repository: context.read<CategoryRepository>(),
          ),
          update: (context, repo, authProvider, previous) {
            final activeVm = previous ?? CategoryViewModel(repository: repo);
            activeVm.updateRepository(repo);

            final userEntity = authProvider.currentUser?.toEntity();
            if (userEntity != null) {
              final localId = userEntity.id ?? 0;
              if (localId > 0 && userEntity.onboardingCompleted == true) {
                if (activeVm.lastLoadedUserId != localId) {
                  activeVm.loadCategories(localId);
                }
              }
            } else {
              activeVm.clearCategories();
            }
            return activeVm;
          },
        ),
      ];
}

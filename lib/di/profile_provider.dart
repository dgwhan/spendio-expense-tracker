import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

// DATA LAYER
import 'package:spend_io_app/features/profile/data/datasources/profile_local_datasource.dart';
import 'package:spend_io_app/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:spend_io_app/features/profile/data/repositories/profile_repository_impl.dart';

// PRESENTATION LAYER
import 'package:spend_io_app/features/profile/presentation/viewmodels/profile_viewmodel.dart';

class ProfileModuleProvider {
  ProfileModuleProvider._();

  static List<SingleChildWidget> get providers => [
        // 1. DATA LAYER
        Provider<ProfileLocalDataSource>(
            create: (_) => ProfileLocalDataSource()),
        Provider<ProfileRemoteDataSource>(
            create: (_) => ProfileRemoteDataSource()),
        ProxyProvider2<ProfileLocalDataSource, ProfileRemoteDataSource,
            ProfileRepositoryImpl>(
          update: (_, local, remote, __) => ProfileRepositoryImpl(
              localDataSource: local, remoteDataSource: remote),
        ),

        // 2. PRESENTATION LAYER
        ChangeNotifierProxyProvider<ProfileRepositoryImpl, ProfileViewModel>(
          create: (context) => ProfileViewModel(
              profileRepository: context.read<ProfileRepositoryImpl>()),
          update: (_, repo, vm) =>
              vm ?? ProfileViewModel(profileRepository: repo),
        ),
      ];
}

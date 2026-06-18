import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:spend_io_app/features/profile/data/datasources/profile_local_datasource.dart';
import 'package:spend_io_app/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:spend_io_app/features/profile/domain/repositories/profile_repository.dart';
import 'package:spend_io_app/features/profile/presentation/viewmodels/profile_viewmodel.dart';

class ProfileModuleProvider {
  ProfileModuleProvider._();

  static List<SingleChildWidget> get providers => [
        Provider<ProfileLocalDataSource>(
          create: (_) => ProfileLocalDataSourceImpl(),
        ),
        ProxyProvider<ProfileLocalDataSource, ProfileRepository>(
          update: (_, local, __) =>
              ProfileRepositoryImpl(localDataSource: local),
        ),
        ChangeNotifierProxyProvider<ProfileRepository, ProfileViewModel>(
          create: (context) => ProfileViewModel(
            profileRepository: context.read<ProfileRepository>(),
          ),
          update: (_, repo, previous) {
            if (previous == null) {
              return ProfileViewModel(profileRepository: repo);
            }
            return previous;
          },
        ),
      ];
}

import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:spend_io_app/features/profile/data/datasources/profile_local_datasource.dart';
import 'package:spend_io_app/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:spend_io_app/features/profile/domain/repositories/profile_repository.dart';
import 'package:spend_io_app/features/profile/domain/usecase/update_app_settings_usecase.dart';
import 'package:spend_io_app/features/profile/presentation/viewmodels/profile_viewmodel.dart';

class ProfileModuleProvider {
  ProfileModuleProvider._();

  static List<SingleChildWidget> get providers => [
        Provider<ProfileLocalDataSource>(
          create: (_) => ProfileLocalDataSourceImpl(),
        ),
        Provider<UpdateAppSettingsUseCase>(
          create: (_) => const UpdateAppSettingsUseCase(),
        ),
        ProxyProvider<ProfileLocalDataSource, ProfileRepository>(
          update: (_, local, __) =>
              ProfileRepositoryImpl(localDataSource: local),
        ),
        ChangeNotifierProxyProvider<ProfileRepository, ProfileViewModel>(
          create: (context) => ProfileViewModel(
            profileRepository: context.read<ProfileRepository>(),
            updateAppSettingsUseCase: context.read<UpdateAppSettingsUseCase>(),
          ),
          update: (context, repo, previous) {
            final useCase = context.read<UpdateAppSettingsUseCase>();
            if (previous == null) {
              return ProfileViewModel(
                profileRepository: repo,
                updateAppSettingsUseCase: useCase,
              );
            }
            return previous;
          },
        ),
      ];
}

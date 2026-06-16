import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

// DATA LAYER
import 'package:spend_io_app/features/auth/data/datasource/auth_local_datasource.dart';
import 'package:spend_io_app/features/auth/data/datasource/auth_remote_datasource.dart';
import 'package:spend_io_app/features/auth/data/repositories/auth_repository_impl.dart';

// DOMAIN LAYER
import 'package:spend_io_app/features/auth/domain/usecases/check_email_usecase.dart';
import 'package:spend_io_app/features/auth/domain/usecases/get_current_user_usecase.dart';

// PRESENTATION LAYER
import 'package:spend_io_app/features/auth/presentation/viewmodels/register_form_viewmodel.dart';
import 'package:spend_io_app/features/auth/presentation/viewmodels/login_form_viewmodel.dart';
import 'package:spend_io_app/features/auth/presentation/providers/auth_provider.dart';

class AuthModuleProvider {
  AuthModuleProvider._();

  static List<SingleChildWidget> get providers => [
        // 1. DATA LAYER
        Provider<AuthLocalDatasource>(create: (_) => AuthLocalDatasource()),
        Provider<AuthRemoteDatasource>(create: (_) => AuthRemoteDatasource()),
        ProxyProvider2<AuthLocalDatasource, AuthRemoteDatasource,
            AuthRepositoryImpl>(
          update: (_, local, remote, __) => AuthRepositoryImpl(local, remote),
        ),

        // 2. DOMAIN LAYER
        ProxyProvider<AuthRepositoryImpl, CheckEmailUseCase>(
          update: (_, repo, previous) => previous ?? CheckEmailUseCase(repo),
        ),
        ProxyProvider<AuthRepositoryImpl, GetCurrentUserUseCase>(
          update: (_, repo, previous) =>
              previous ?? GetCurrentUserUseCase(repo),
        ),

        // 3. PRESENTATION LAYER
        ChangeNotifierProxyProvider<CheckEmailUseCase, RegisterFormViewModel>(
          create: (context) => RegisterFormViewModel(
            checkEmailUseCase: context.read<CheckEmailUseCase>(),
          ),
          update: (_, useCase, vm) =>
              vm ?? RegisterFormViewModel(checkEmailUseCase: useCase),
        ),
        ChangeNotifierProvider(
          create: (_) => LoginFormViewModel(),
        ),
        ChangeNotifierProxyProvider<AuthRepositoryImpl, AuthProvider>(
          create: (context) => AuthProvider(
            repository: context.read<AuthRepositoryImpl>(),
          ),
          update: (_, repo, provider) =>
              provider ?? AuthProvider(repository: repo),
        ),
      ];
}

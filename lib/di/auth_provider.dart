import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

// DATA LAYER
import 'package:spend_io_app/features/auth/data/datasource/auth_local_datasource.dart';
import 'package:spend_io_app/features/auth/data/datasource/auth_remote_datasource.dart';
import 'package:spend_io_app/features/auth/data/datasource/google_auth_datasource.dart';
import 'package:spend_io_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:spend_io_app/features/auth/data/services/auth_sync_service.dart';
import 'package:spend_io_app/features/auth/data/services/google_signin_service.dart';

// DOMAIN LAYER
import 'package:spend_io_app/features/auth/domain/usecases/check_email_usecase.dart';
import 'package:spend_io_app/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:spend_io_app/features/auth/domain/usecases/sign_in_with_google_usecase.dart';

// PRESENTATION LAYER
import 'package:spend_io_app/features/auth/presentation/viewmodels/register_form_viewmodel.dart';
import 'package:spend_io_app/features/auth/presentation/viewmodels/login_form_viewmodel.dart';
import 'package:spend_io_app/features/auth/presentation/providers/auth_provider.dart';

class AuthModuleProvider {
  AuthModuleProvider._();

  static List<SingleChildWidget> get providers => [
        //DATA LAYER
        Provider<AuthLocalDatasource>(create: (_) => AuthLocalDatasource()),
        Provider<AuthRemoteDatasource>(create: (_) => AuthRemoteDatasource()),
        Provider<GoogleAuthDatasource>(create: (_) => GoogleAuthDatasource()),
        ProxyProvider<AuthLocalDatasource, AuthSyncService>(
          update: (_, local, __) => AuthSyncService(local),
        ),
        ProxyProvider4<GoogleAuthDatasource, AuthRemoteDatasource,
            AuthLocalDatasource, AuthSyncService, GoogleSigninService>(
          update: (_, googleDs, remote, local, syncService, __) =>
              GoogleSigninService(
            googleAuthDatasource: googleDs,
            remoteDatasource: remote,
            localDatasource: local,
            authSyncService: syncService,
          ),
        ),
        ProxyProvider4<AuthLocalDatasource, AuthRemoteDatasource,
            GoogleSigninService, AuthSyncService, AuthRepositoryImpl>(
          update: (_, local, remote, googleService, syncService, __) =>
              AuthRepositoryImpl(local, remote, googleService, syncService),
        ),

        //DOMAIN LAYER
        ProxyProvider<AuthRepositoryImpl, CheckEmailUseCase>(
          update: (_, repo, previous) => previous ?? CheckEmailUseCase(repo),
        ),
        ProxyProvider<AuthRepositoryImpl, GetCurrentUserUseCase>(
          update: (_, repo, previous) =>
              previous ?? GetCurrentUserUseCase(repo),
        ),
        ProxyProvider<AuthRepositoryImpl, SignInWithGoogleUseCase>(
          update: (_, repo, previous) =>
              previous ?? SignInWithGoogleUseCase(repo),
        ),

        //PRESENTATION LAYER
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

import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

// DATA LAYER
import 'package:spend_io_app/features/account/data/datasource/account_local_data_source.dart';
import 'package:spend_io_app/features/account/data/datasource/account_remote_data_source.dart';
import 'package:spend_io_app/features/account/data/repositories/account_repository_impl.dart';

// DOMAIN LAYER (USE CASES)
import 'package:spend_io_app/features/account/domain/usecase/get_accounts_usecase.dart';
import 'package:spend_io_app/features/account/domain/usecase/create_account_usecase.dart';
import 'package:spend_io_app/features/account/domain/usecase/update_account_usecase.dart';
import 'package:spend_io_app/features/account/domain/usecase/delete_account_usecase.dart';

// PRESENTATION LAYER (VIEWMODEL & AUTHDEPENDENCY)
import 'package:spend_io_app/features/account/presentation/viewmodels/account_viewmodel.dart';
import 'package:spend_io_app/features/auth/presentation/providers/auth_provider.dart';

class AccountProvider {
  AccountProvider._();

  static List<SingleChildWidget> get providers => [
        // 1. DATA LAYER
        Provider<AccountLocalDataSource>(
          create: (_) => AccountLocalDataSourceImpl(),
        ),
        Provider<AccountRemoteDataSource>(
          create: (_) => AccountRemoteDataSourceImpl(),
        ),
        ProxyProvider2<AccountLocalDataSource, AccountRemoteDataSource,
            AccountRepositoryImpl>(
          update: (_, local, remote, __) => AccountRepositoryImpl(
              localDataSource: local, remoteDataSource: remote),
        ),

        // 2. DOMAIN LAYER (USE CASES)
        ProxyProvider<AccountRepositoryImpl, GetAccountsUseCase>(
          update: (_, repo, previous) => previous ?? GetAccountsUseCase(repo),
        ),
        ProxyProvider<AccountRepositoryImpl, CreateAccountUseCase>(
          update: (_, repo, previous) => previous ?? CreateAccountUseCase(repo),
        ),
        ProxyProvider<AccountRepositoryImpl, UpdateAccountUseCase>(
          update: (_, repo, previous) => previous ?? UpdateAccountUseCase(repo),
        ),
        ProxyProvider<AccountRepositoryImpl, DeleteAccountUseCase>(
          update: (_, repo, previous) => previous ?? DeleteAccountUseCase(repo),
        ),

        // 3. PRESENTATION LAYER (VIEWMODEL WITH INJECTOR)
        ChangeNotifierProxyProvider<AuthProvider, AccountViewModel>(
          create: (context) => AccountViewModel(
            getAccountsUseCase: context.read<GetAccountsUseCase>(),
            createAccountUseCase: context.read<CreateAccountUseCase>(),
            updateAccountUseCase: context.read<UpdateAccountUseCase>(),
            deleteAccountUseCase: context.read<DeleteAccountUseCase>(),
          ),
          update: (context, authProvider, vm) {
            final activeVm = vm ??
                AccountViewModel(
                  getAccountsUseCase: context.read<GetAccountsUseCase>(),
                  createAccountUseCase: context.read<CreateAccountUseCase>(),
                  updateAccountUseCase: context.read<UpdateAccountUseCase>(),
                  deleteAccountUseCase: context.read<DeleteAccountUseCase>(),
                );

            final userEntity = authProvider.currentUser?.toEntity();

            if (userEntity != null) {
              final localId = userEntity.id ?? 0;
              final String remoteUid =
                  fb_auth.FirebaseAuth.instance.currentUser?.uid ?? '';

              // Thực hiện nạp tài khoản tự động chuẩn chỉ Phase 02
              if (localId > 0 &&
                  remoteUid.isNotEmpty &&
                  userEntity.onboardingCompleted == true) {
                activeVm.loadAccounts(localId, remoteUid);
              }
            } else {
              activeVm.clearAccounts();
            }
            return activeVm;
          },
        ),
      ];
}

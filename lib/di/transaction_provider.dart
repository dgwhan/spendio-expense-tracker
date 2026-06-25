import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:spend_io_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:spend_io_app/features/account/domain/repositories/account_repository.dart';
import 'package:spend_io_app/features/transaction/data/datasource/transaction_local_data_source.dart';
import 'package:spend_io_app/features/transaction/data/datasource/transaction_remote_data_source.dart';
import 'package:spend_io_app/features/transaction/data/repositories/transaction_repository_impl.dart';
import 'package:spend_io_app/features/transaction/domain/repositories/transaction_repository.dart';
import 'package:spend_io_app/features/transaction/domain/usecases/create_transaction.dart';
import 'package:spend_io_app/features/transaction/presentation/viewmodels/transaction_viewmodel.dart';

class TransactionProvider {
  TransactionProvider._();

  static List<SingleChildWidget> get providers => [
        // DATA LAYER
        Provider<TransactionLocalDataSource>(
          create: (_) => TransactionLocalDataSourceImpl(),
        ),
        Provider<TransactionRemoteDataSource>(
          create: (_) => TransactionRemoteDataSourceImpl(),
        ),
        ProxyProvider3<TransactionLocalDataSource, TransactionRemoteDataSource,
            AccountRepository, TransactionRepository>(
          update: (
            context,
            local,
            remote,
            accountRepository,
            __,
          ) {
            final remoteUid = FirebaseAuth.instance.currentUser?.uid ?? '';
            return TransactionRepositoryImpl(
              localDataSource: local,
              remoteDataSource: remote,
              accountRepository: accountRepository,
              remoteUid: remoteUid,
            );
          },
        ),
        ProxyProvider<TransactionRepository, CreateTransaction>(
          update: (_, txRepo, previous) =>
              previous ?? CreateTransaction(transactionRepository: txRepo),
        ),

        ChangeNotifierProxyProvider3<CreateTransaction, TransactionRepository,
            AuthProvider, TransactionViewModel>(
          create: (context) => TransactionViewModel(
            repository: context.read<TransactionRepository>(),
            createTransactionUseCase: context.read<CreateTransaction>(),
          ),
          update: (_, createTx, txRepo, authProvider, previous) {
            final vm = previous ??
                TransactionViewModel(
                  repository: txRepo,
                  createTransactionUseCase: createTx,
                );
            vm.updateUserId(authProvider.currentUser?.id);
            if (authProvider.currentUser == null) {
              vm.clearTransactions();
            }
            return vm;
          },
        ),
      ];
}

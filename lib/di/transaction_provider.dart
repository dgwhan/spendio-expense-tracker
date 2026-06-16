import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

// DATA LAYER
import 'package:spend_io_app/features/transaction/data/datasource/transaction_local_data_source.dart';
import 'package:spend_io_app/features/transaction/data/datasource/transaction_remote_data_source.dart';
import 'package:spend_io_app/features/transaction/data/repositories/transaction_repository_impl.dart';
import 'package:spend_io_app/features/transaction/domain/repositories/transaction_repository.dart';

// DOMAIN LAYER
import 'package:spend_io_app/features/transaction/domain/usecases/create_transaction.dart';
import 'package:spend_io_app/features/transaction/domain/usecases/update_wallet_balance.dart';

// PRESENTATION LAYER
import 'package:spend_io_app/features/transaction/presentation/viewmodels/transaction_viewmodel.dart';

// AUTH
import 'package:spend_io_app/features/auth/presentation/providers/auth_provider.dart';

// WALLET LAYER
import 'package:spend_io_app/features/wallet/domain/repositories/wallet_repository.dart';

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

        ProxyProvider<AuthProvider, UpdateWalletBalance>(
          update: (context, authProvider, previous) {
            final walletRepo = context.read<WalletRepository>();

            final localUserId = authProvider.currentUser?.id ?? 0;
            final remoteUid = FirebaseAuth.instance.currentUser?.uid ?? '';

            if (previous != null &&
                previous.localUserId == localUserId &&
                previous.remoteUid == remoteUid) {
              return previous;
            }

            return UpdateWalletBalance(
              walletRepo,
              localUserId: localUserId,
              remoteUid: remoteUid,
            );
          },
        ),

        // TransactionRepository receives the use case via ProxyProvider3.
        ProxyProvider3<TransactionLocalDataSource, TransactionRemoteDataSource,
            UpdateWalletBalance, TransactionRepository>(
          update: (context, local, remote, walletUpdater, __) {
            final remoteUid = FirebaseAuth.instance.currentUser?.uid ?? '';
            return TransactionRepositoryImpl(
              localDataSource: local,
              remoteDataSource: remote,
              updateWalletBalance: walletUpdater,
              remoteUid: remoteUid,
            );
          },
        ),

        ProxyProvider<TransactionRepository, CreateTransaction>(
          update: (_, txRepo, previous) =>
              previous ?? CreateTransaction(transactionRepository: txRepo),
        ),

        ChangeNotifierProxyProvider2<CreateTransaction, TransactionRepository,
            TransactionViewModel>(
          create: (context) => TransactionViewModel(
            repository: context.read<TransactionRepository>(),
            createTransactionUseCase: context.read<CreateTransaction>(),
          ),
          update: (_, createTx, txRepo, previous) =>
              previous ??
              TransactionViewModel(
                repository: txRepo,
                createTransactionUseCase: createTx,
              ),
        ),
      ];
}

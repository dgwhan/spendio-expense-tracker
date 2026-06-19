import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:spend_io_app/features/account/domain/repositories/account_repository.dart';

// DATA LAYER
import 'package:spend_io_app/features/transaction/data/datasource/transaction_local_data_source.dart';
import 'package:spend_io_app/features/transaction/data/datasource/transaction_remote_data_source.dart';
import 'package:spend_io_app/features/transaction/data/repositories/transaction_repository_impl.dart';
import 'package:spend_io_app/features/transaction/domain/repositories/transaction_repository.dart';

// DOMAIN LAYER
import 'package:spend_io_app/features/transaction/domain/usecases/create_transaction.dart';

// PRESENTATION LAYER
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

        // TransactionRepository receives the use case via ProxyProvider3.
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

        // Khong tiem truc tiep BudgetViewModel o day vi se tao dependency
        // cycle giua module Transaction va Budget (BudgetProgressCalculator
        // can doc TransactionRepository, neu Transaction lai doc nguoc
        // BudgetViewModel se khong co thu tu khai bao nao hop le).
        // Callback onTransactionBalanceChanged duoc gan o tang App widget,
        // xem app.dart.
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

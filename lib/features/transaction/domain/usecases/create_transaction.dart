import 'package:spend_io_app/features/transaction/domain/entities/transaction_entity.dart';
import 'package:spend_io_app/features/transaction/domain/repositories/transaction_repository.dart';

class CreateTransaction {
  final TransactionRepository transactionRepository;

  CreateTransaction({
    required this.transactionRepository,
  });

  Future<void> call(TransactionEntity transaction) async {
    await transactionRepository.createTransaction(transaction);
  }
}

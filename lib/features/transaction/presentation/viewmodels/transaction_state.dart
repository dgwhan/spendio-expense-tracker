import 'package:spend_io_app/features/transaction/domain/entities/transaction_entity.dart';

class TransactionState {
  final bool isLoading;
  final List<TransactionEntity> transactions;
  final String? error;

  const TransactionState({
    this.isLoading = false,
    this.transactions = const [],
    this.error,
  });

  TransactionState copyWith({
    bool? isLoading,
    List<TransactionEntity>? transactions,
    String? error,
  }) {
    return TransactionState(
      isLoading: isLoading ?? this.isLoading,
      transactions: transactions ?? this.transactions,
      error: error,
    );
  }
}

import '../entities/transaction_entity.dart';
import '../entities/transaction_type.dart';

enum OperationType { create, update, delete }

class WalletBalanceService {
  static double recalculate({
    required double currentBalance,
    required TransactionEntity tx,
    required OperationType operation,
    TransactionEntity? oldTx,
  }) {
    double balance = currentBalance;

    switch (operation) {
      case OperationType.create:
        balance += _apply(tx);
        break;

      case OperationType.delete:
        balance -= _apply(tx); // Đảo ngược tác động dòng tiền khi xóa
        break;

      case OperationType.update:
        if (oldTx != null) {
          balance -= _apply(oldTx); // Khấu trừ  dòng tiền của giao dịch cũ
        }
        balance += _apply(tx); // Cộng dồn dòng tiền của giao dịch mới
        break;
    }

    return balance;
  }

  static double _apply(TransactionEntity tx) {
    return tx.type == TransactionType.income ? tx.amount : -tx.amount;
  }
}

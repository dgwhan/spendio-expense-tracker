import 'package:spend_io_app/features/home/data/models/recent_transaction_model.dart';

class TransactionDayGroup {
  final DateTime date;
  final List<RecentTransactionModel> items;
  final double totalIncome;
  final double totalExpense;

  const TransactionDayGroup({
    required this.date,
    required this.items,
    required this.totalIncome,
    required this.totalExpense,
  });
}

List<TransactionDayGroup> groupByDate(List<RecentTransactionModel> transactions) {
  final Map<DateTime, List<RecentTransactionModel>> groups = {};
  
  for (final tx in transactions) {
    final dateKey = DateTime(tx.date.year, tx.date.month, tx.date.day);
    if (!groups.containsKey(dateKey)) {
      groups[dateKey] = [];
    }
    groups[dateKey]!.add(tx);
  }

  final List<TransactionDayGroup> sortedGroups = [];
  final List<DateTime> sortedKeys = groups.keys.toList()..sort((a, b) {
    return b.compareTo(a);
  });

  for (final date in sortedKeys) {
    final items = groups[date]!;
    double totalIncome = 0;
    double totalExpense = 0;
    
    for (final item in items) {
      if (item.isExpense) {
        totalExpense += item.amount;
      } else {
        totalIncome += item.amount;
      }
    }
    
    sortedGroups.add(TransactionDayGroup(
      date: date,
      items: items,
      totalIncome: totalIncome,
      totalExpense: totalExpense,
    ));
  }

  return sortedGroups;
}

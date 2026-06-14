import 'package:spend_io_app/features/transaction/data/models/transaction_model.dart';

/// [App Location] Core Shared Utilities.
/// [Core Function] Groups a flat list of transaction models into day-based bucket segments for timeline rendering.
class TransactionDayGroup {
  final DateTime date;
  final List<TransactionModel> items;
  final double totalIncome;
  final double totalExpense;

  const TransactionDayGroup({
    required this.date,
    required this.items,
    required this.totalIncome,
    required this.totalExpense,
  });
}

/// Utility function to partition transactions chronologically by calendar day.
List<TransactionDayGroup> groupByDate(List<TransactionModel> transactions) {
  final Map<DateTime, List<TransactionModel>> groups = {};

  // Sort transactions by date descending (Newest first)
  final sortedTransactions = List<TransactionModel>.from(transactions)
    ..sort((a, b) => b.date.compareTo(a.date));

  for (final tx in sortedTransactions) {
    final dateZero = DateTime(tx.date.year, tx.date.month, tx.date.day);
    if (!groups.containsKey(dateZero)) {
      groups[dateZero] = [];
    }
    groups[dateZero]!.add(tx);
  }

  final List<TransactionDayGroup> dayGroups = [];

  groups.forEach((date, items) {
    double income = 0;
    double expense = 0;

    for (final tx in items) {
      if (tx.isExpense) {
        expense += tx.amount;
      } else {
        income += tx.amount;
      }
    }

    dayGroups.add(
      TransactionDayGroup(
        date: date,
        items: items,
        totalIncome: income,
        totalExpense: expense,
      ),
    );
  });

  return dayGroups;
}

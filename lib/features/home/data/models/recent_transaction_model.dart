/// TEMPORARY MODEL (Phase 02B only)
/// Will be replaced by TransactionEntity in Phase 03 Transaction Engine
class RecentTransactionModel {
  final String id;
  final String title;
  final String category;
  final double amount;
  final DateTime date;
  final bool isExpense;

  const RecentTransactionModel({
    required this.id,
    required this.title,
    required this.category,
    required this.amount,
    required this.date,
    required this.isExpense,
  });
}

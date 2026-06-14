import 'package:spend_io_app/features/home/data/models/recent_transaction_model.dart';

List<RecentTransactionModel> generateMockTransactions(String accountId) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = today.subtract(const Duration(days: 1));
  final fiveDaysAgo = today.subtract(const Duration(days: 5));
  final fifteenDaysAgo = today.subtract(const Duration(days: 15));
  final lastMonth = DateTime(now.year, now.month - 1, 15);
  final thisYearEarlier = DateTime(now.year, 1, 10);

  return [
    // Today
    RecentTransactionModel(
      id: 'tx_1_$accountId',
      title: 'Starbucks Coffee',
      category: 'Food & Drink',
      amount: 65000,
      date: today.add(const Duration(hours: 10, minutes: 15)),
      isExpense: true,
    ),
    RecentTransactionModel(
      id: 'tx_2_$accountId',
      title: 'Grab Ride',
      category: 'Transport',
      amount: 45000,
      date: today.add(const Duration(hours: 14, minutes: 30)),
      isExpense: true,
    ),
    RecentTransactionModel(
      id: 'tx_3_$accountId',
      title: 'Salary Deposit',
      category: 'Salary',
      amount: 25000000,
      date: today.add(const Duration(hours: 8, minutes: 0)),
      isExpense: false,
    ),
    
    // Yesterday
    RecentTransactionModel(
      id: 'tx_4_$accountId',
      title: 'Grocery Store Store',
      category: 'Groceries',
      amount: 320000,
      date: yesterday.add(const Duration(hours: 17, minutes: 45)),
      isExpense: true,
    ),
    RecentTransactionModel(
      id: 'tx_5_$accountId',
      title: 'Netflix Subscription',
      category: 'Entertainment',
      amount: 260000,
      date: yesterday.add(const Duration(hours: 9, minutes: 15)),
      isExpense: true,
    ),

    // Earlier this month
    RecentTransactionModel(
      id: 'tx_6_$accountId',
      title: 'Petrol Fuel',
      category: 'Transport',
      amount: 90000,
      date: fiveDaysAgo.add(const Duration(hours: 11, minutes: 0)),
      isExpense: true,
    ),
    RecentTransactionModel(
      id: 'tx_7_$accountId',
      title: 'CGV Cinema Movie',
      category: 'Entertainment',
      amount: 210000,
      date: fiveDaysAgo.add(const Duration(hours: 20, minutes: 30)),
      isExpense: true,
    ),
    RecentTransactionModel(
      id: 'tx_8_$accountId',
      title: 'Dividend Payout',
      category: 'Investment',
      amount: 1500000,
      date: fifteenDaysAgo.add(const Duration(hours: 10, minutes: 0)),
      isExpense: false,
    ),

    // Last Month
    RecentTransactionModel(
      id: 'tx_9_$accountId',
      title: 'Electricity Bill',
      category: 'Bills',
      amount: 1200000,
      date: lastMonth.add(const Duration(hours: 15, minutes: 0)),
      isExpense: true,
    ),
    RecentTransactionModel(
      id: 'tx_10_$accountId',
      title: 'Nike Air Max',
      category: 'Shopping',
      amount: 2300000,
      date: lastMonth.add(const Duration(hours: 19, minutes: 20)),
      isExpense: true,
    ),

    // This Year Earlier
    RecentTransactionModel(
      id: 'tx_11_$accountId',
      title: 'New Year Bonus',
      category: 'Bonus',
      amount: 10000000,
      date: thisYearEarlier.add(const Duration(hours: 9, minutes: 0)),
      isExpense: false,
    ),
  ];
}

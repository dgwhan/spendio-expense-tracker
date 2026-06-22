import 'package:spend_io_app/features/insight/data/models/insight_spending_item.dart';

class BarChartItem {
  final String label;
  final double value;

  const BarChartItem({required this.label, required this.value});
}

class InsightState {
  final String activeFilter; 
  final double totalIncome;
  final double totalExpense;
  final double netBalance;
  final List<InsightSpendingItem> spendingItems;
  final List<BarChartItem> barItems;

  const InsightState({
    this.activeFilter = 'Month',
    this.totalIncome = 0.0,
    this.totalExpense = 0.0,
    this.netBalance = 0.0,
    this.spendingItems = const [],
    this.barItems = const [],
  });

  InsightState copyWith({
    String? activeFilter,
    double? totalIncome,
    double? totalExpense,
    double? netBalance,
    List<InsightSpendingItem>? spendingItems,
    List<BarChartItem>? barItems,
  }) {
    return InsightState(
      activeFilter: activeFilter ?? this.activeFilter,
      totalIncome: totalIncome ?? this.totalIncome,
      totalExpense: totalExpense ?? this.totalExpense,
      netBalance: netBalance ?? this.netBalance,
      spendingItems: spendingItems ?? this.spendingItems,
      barItems: barItems ?? this.barItems,
    );
  }
}

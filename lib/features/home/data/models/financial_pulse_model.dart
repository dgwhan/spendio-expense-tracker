class DailySpendingModel {
  final String dayName;
  final double amount;
  final double densityRatio;

  const DailySpendingModel({
    required this.dayName,
    required this.amount,
    required this.densityRatio,
  });
}

class FinancialPulseModel {
  final double thisWeekTotal;
  final double comparePercentage;
  final bool isDecreased;
  final List<DailySpendingModel> dailySpendings;
  final String highestDayName;
  final double highestDayAmount;
  final String topCategoryName;
  final int topCategoryPercentage;
  final String aiRecommendation;

  const FinancialPulseModel({
    required this.thisWeekTotal,
    required this.comparePercentage,
    required this.isDecreased,
    required this.dailySpendings,
    required this.highestDayName,
    required this.highestDayAmount,
    required this.topCategoryName,
    required this.topCategoryPercentage,
    required this.aiRecommendation,
  });
}

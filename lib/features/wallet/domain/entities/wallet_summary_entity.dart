class WalletSummaryEntity {
  final double totalAssets;
  final double monthlyBudget;
  final double totalSaved;
  final int activeGoals;
  final int remainingDays;

  const WalletSummaryEntity({
    required this.totalAssets,
    required this.monthlyBudget,
    required this.totalSaved,
    required this.activeGoals,
    required this.remainingDays,
  });

  static const empty = WalletSummaryEntity(
    totalAssets: 0,
    monthlyBudget: 0,
    totalSaved: 0,
    activeGoals: 0,
    remainingDays: 0,
  );

  double get netWorth => totalAssets + totalSaved;
}

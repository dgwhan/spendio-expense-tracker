class WalletSummaryEntity {
  final double totalAssets;
  final double monthlyBudget;
  final double totalSaved;
  final int activeGoals;

  const WalletSummaryEntity(
      {required this.totalAssets,
      required this.monthlyBudget,
      required this.totalSaved,
      required this.activeGoals});
}

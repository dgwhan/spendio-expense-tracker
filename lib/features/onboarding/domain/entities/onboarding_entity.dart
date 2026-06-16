class OnboardingEntity {
  final String? displayName;
  final String? occupation;
  final List<String> goals;
  final String? currencyCode;
  final double? initialBalance;
  final bool onboardingCompleted;
  final String? walletId;

  const OnboardingEntity({
    this.displayName,
    this.occupation,
    this.goals = const [],
    this.currencyCode,
    this.initialBalance,
    this.onboardingCompleted = false,
    this.walletId,
  });
}

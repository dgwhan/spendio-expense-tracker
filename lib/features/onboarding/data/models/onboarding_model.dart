class OnboardingModel {
  final String? displayName;
  final String? occupation;
  final List<String> goals;
  final String? currencyCode;
  final double? initialBalance;
  final bool onboardingCompleted;
  final String? walletId;

  const OnboardingModel({
    this.displayName,
    this.occupation,
    this.goals = const [],
    this.currencyCode,
    this.initialBalance,
    this.onboardingCompleted = false,
    this.walletId,
  });

  Map<String, dynamic> toMap() {
    return {
      'display_name': displayName,
      'occupation': occupation,
      'goals': goals,
      'currency_code': currencyCode,
      'initial_balance': initialBalance,
      'onboarding_completed': onboardingCompleted,
      'wallet_id': walletId,
    };
  }

  factory OnboardingModel.fromMap(
    Map<String, dynamic> map,
  ) {
    return OnboardingModel(
      displayName: map['display_name'] as String?,
      occupation: map['occupation'] as String?,
      goals: List<String>.from(
        map['goals'] ?? [],
      ),
      currencyCode: map['currency_code'] as String?,
      initialBalance: (map['initial_balance'] as num?)
          ?.toDouble(), // Khôi phục bốc chuẩn double
      onboardingCompleted: map['onboarding_completed'] == 1 ||
          map['onboarding_completed'] == true,
      walletId: map['wallet_id'] as String?,
    );
  }

  OnboardingModel copyWith({
    String? displayName,
    String? occupation,
    List<String>? goals,
    String? currencyCode,
    double? initialBalance,
    bool? onboardingCompleted,
    String? walletId,
  }) {
    return OnboardingModel(
      displayName: displayName ?? this.displayName,
      occupation: occupation ?? this.occupation,
      goals: goals ?? this.goals,
      currencyCode: currencyCode ?? this.currencyCode,
      initialBalance: initialBalance ?? this.initialBalance,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      walletId: walletId ?? this.walletId,
    );
  }
}

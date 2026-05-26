class OnboardingModel {
  final String? displayName;

  final String? occupation;

  final List<String> goals;

  final String? currencyCode;

  final double? initialBalance;

  final bool onboardingCompleted;

  const OnboardingModel({
    this.displayName,
    this.occupation,
    this.goals = const [],
    this.currencyCode,
    this.initialBalance,
    this.onboardingCompleted = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'display_name': displayName,
      'occupation': occupation,
      'goals': goals,
      'currency_code': currencyCode,
      'initial_balance': initialBalance,
      'onboarding_completed': onboardingCompleted,
    };
  }

  factory OnboardingModel.fromMap(
    Map<String, dynamic> map,
  ) {
    return OnboardingModel(
      displayName: map['display_name'],
      occupation: map['occupation'],
      goals: List<String>.from(
        map['goals'] ?? [],
      ),
      currencyCode: map['currency_code'],
      initialBalance: map['initial_balance'],
      onboardingCompleted: map['onboarding_completed'] ?? false,
    );
  }

  OnboardingModel copyWith({
    String? displayName,
    String? occupation,
    List<String>? goals,
    String? currencyCode,
    double? initialBalance,
    bool? onboardingCompleted,
  }) {
    return OnboardingModel(
      displayName: displayName ?? this.displayName,
      occupation: occupation ?? this.occupation,
      goals: goals ?? this.goals,
      currencyCode: currencyCode ?? this.currencyCode,
      initialBalance: initialBalance ?? this.initialBalance,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
    );
  }
}

class UserEntity {
  final int? id;
  final String email;
  final String password;
  final String? occupation;
  final String? financialGoal;
  final String? preferredCurrencyCode;
  final bool onboardingCompleted;
  final String? displayNameField;

  UserEntity({
    this.id,
    required this.email,
    required this.password,
    this.occupation,
    this.financialGoal,
    this.preferredCurrencyCode,
    this.onboardingCompleted = false,
    this.displayNameField,
  });

  String get displayName => (displayNameField != null && displayNameField!.isNotEmpty)
      ? displayNameField!
      : email.split('@').first;

  String? get currencyCode => preferredCurrencyCode;

  UserEntity copyWith({
    int? id,
    String? email,
    String? password,
    String? occupation,
    String? financialGoal,
    String? preferredCurrencyCode,
    bool? onboardingCompleted,
    String? displayNameField,
  }) {
    return UserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      password: password ?? this.password,
      occupation: occupation ?? this.occupation,
      financialGoal: financialGoal ?? this.financialGoal,
      preferredCurrencyCode: preferredCurrencyCode ?? this.preferredCurrencyCode,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      displayNameField: displayNameField ?? this.displayNameField,
    );
  }
}


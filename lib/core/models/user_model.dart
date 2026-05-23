/// application user model
class UserModel {
  final int? id;

  final String email;
  final String password;

  /// generated from email
  final String displayName;

  /// editable in profile later
  final String? fullName;

  final String? occupation;

  final String? financialGoal;

  final String? currency;

  final bool onboardingCompleted;

  final DateTime createdAt;

  const UserModel({
    this.id,
    required this.email,
    required this.password,
    required this.displayName,
    this.fullName,
    this.occupation,
    this.financialGoal,
    this.currency,
    this.onboardingCompleted = false,
    required this.createdAt,
  });

  /// convert object to map
  Map<String, dynamic> toMap() {
    return {
      'id': id,

      'email': email,
      'password': password,

      'display_name':
          displayName,

      'full_name': fullName,

      'occupation': occupation,

      'financial_goal':
          financialGoal,

      'currency': currency,

      'onboarding_completed':
          onboardingCompleted
              ? 1
              : 0,

      'created_at':
          createdAt.toIso8601String(),
    };
  }

  /// create object from map
  factory UserModel.fromMap(
    Map<String, dynamic> map,
  ) {
    return UserModel(
      id: map['id'],

      email: map['email'] ?? '',

      password:
          map['password'] ?? '',

      displayName:
          map['display_name'] ?? '',

      fullName:
          map['full_name'],

      occupation:
          map['occupation'],

      financialGoal:
          map['financial_goal'],

      currency:
          map['currency'],

      onboardingCompleted:
          map['onboarding_completed'] ==
              1,

      createdAt: DateTime.parse(
        map['created_at'],
      ),
    );
  }

  /// clone object with new values
  UserModel copyWith({
    int? id,
    String? email,
    String? password,
    String? displayName,
    String? fullName,
    String? occupation,
    String? financialGoal,
    String? currency,
    bool? onboardingCompleted,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,

      email: email ?? this.email,

      password:
          password ?? this.password,

      displayName:
          displayName ??
              this.displayName,

      fullName:
          fullName ?? this.fullName,

      occupation:
          occupation ??
              this.occupation,

      financialGoal:
          financialGoal ??
              this.financialGoal,

      currency:
          currency ?? this.currency,

      onboardingCompleted:
          onboardingCompleted ??
              this.onboardingCompleted,

      createdAt:
          createdAt ?? this.createdAt,
    );
  }
}
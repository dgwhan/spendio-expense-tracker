import '../../domain/entities/user_entity.dart';

class UserModel {
  final int? id;
  final String email;
  final String password;
  final String displayName;
  final String? fullName;
  final String? occupation;
  final String? financialGoal;
  final String? preferredCurrencyCode;
  final bool onboardingCompleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserModel({
    this.id,
    required this.email,
    required this.password,
    required this.displayName,
    this.fullName,
    this.occupation,
    this.financialGoal,
    this.preferredCurrencyCode,
    this.onboardingCompleted = false,
    required this.createdAt,
    required this.updatedAt,
  });

  String? get currencyCode => preferredCurrencyCode;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'password': password,
      'display_name': displayName,
      'full_name': fullName,
      'occupation': occupation,
      'financial_goal': financialGoal,
      'preferred_currency_code': preferredCurrencyCode,
      'onboarding_completed': onboardingCompleted ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      email: map['email'] ?? '',
      password: map['password'] ?? '',
      displayName: map['display_name'] ?? '',
      fullName: map['full_name'],
      occupation: map['occupation'],
      financialGoal: map['financial_goal'],
      preferredCurrencyCode: map['preferred_currency_code'] ?? map['currency_code'] ?? map['currency'],
      onboardingCompleted: map['onboarding_completed']?.toString() == '1' ||
          map['onboarding_completed']?.toString() == 'true',
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : DateTime.now(),
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : DateTime.now(),
    );
  }

  UserModel copyWith({
    int? id,
    String? email,
    String? password,
    String? displayName,
    String? fullName,
    String? occupation,
    String? financialGoal,
    String? preferredCurrencyCode,
    bool? onboardingCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      password: password ?? this.password,
      displayName: displayName ?? this.displayName,
      fullName: fullName ?? this.fullName,
      occupation: occupation ?? this.occupation,
      financialGoal: financialGoal ?? this.financialGoal,
      preferredCurrencyCode: preferredCurrencyCode ?? this.preferredCurrencyCode,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  UserEntity toEntity() {
    return UserEntity(
      id: id,
      email: email,
      password: password,
      occupation: occupation,
      financialGoal: financialGoal,
      preferredCurrencyCode: preferredCurrencyCode,
      onboardingCompleted: onboardingCompleted,
      displayNameField: displayName,
    );
  }
}

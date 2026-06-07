// chức năng: định nghĩa đối tượng ng dùng

class UserEntity {
  final int? id;
  final String email;
  final String password;
  final String? occupation;
  final String? financialGoal;
  final String? currency;
  final bool onboardingCompleted;

  UserEntity({
    this.id,
    required this.email,
    required this.password,
    this.occupation,
    this.financialGoal,
    this.currency,
    this.onboardingCompleted = false ,
  });
}
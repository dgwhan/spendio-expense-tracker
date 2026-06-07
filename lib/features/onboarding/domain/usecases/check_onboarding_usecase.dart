import '../repositories/onboarding_repository.dart';

class CheckOnboardingUseCase {
  final OnboardingRepository repository;

  const CheckOnboardingUseCase({
    required this.repository,
  });

  Future<bool> call({
    required String email,
  }) async {
    return repository.checkCompleted(
      email: email,
    );
  }
}

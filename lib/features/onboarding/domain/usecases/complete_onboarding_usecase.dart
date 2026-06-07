import '../repositories/onboarding_repository.dart';

class CompleteOnboardingUseCase {
  final OnboardingRepository repository;

  const CompleteOnboardingUseCase({
    required this.repository,
  });

  Future<void> call({
    required String email,
  }) async {
    await repository.completeOnboarding(
      email: email,
    );
  }
}

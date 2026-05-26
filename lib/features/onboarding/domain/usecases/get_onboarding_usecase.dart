import '../entities/onboarding_entity.dart';

import '../repositories/onboarding_repository.dart';

class GetOnboardingUseCase {
  final OnboardingRepository repository;

  const GetOnboardingUseCase({
    required this.repository,
  });

  Future<OnboardingEntity?> call({
    required String email,
  }) async {
    return repository.getOnboarding(
      email: email,
    );
  }
}

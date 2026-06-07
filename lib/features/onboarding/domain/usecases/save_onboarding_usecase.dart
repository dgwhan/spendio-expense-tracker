import '../entities/onboarding_entity.dart';

import '../repositories/onboarding_repository.dart';

class SaveOnboardingUseCase {
  final OnboardingRepository repository;

  const SaveOnboardingUseCase({
    required this.repository,
  });

  Future<void> call({
    required String email,
    required OnboardingEntity entity,
  }) async {
    await repository.saveOnboarding(
      email: email,
      entity: entity,
    );
  }
}

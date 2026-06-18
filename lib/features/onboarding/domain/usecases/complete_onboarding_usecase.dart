import '../../domain/entities/onboarding_entity.dart';
import '../repositories/onboarding_repository.dart';

class CompleteOnboardingUseCase {
  final OnboardingRepository repository;

  const CompleteOnboardingUseCase({
    required this.repository,
  });

  Future<void> call({
    required String email,
    required OnboardingEntity entity,
  }) async {
    await repository.completeOnboarding(
      email: email,
      entity: entity,
    );
  }
}

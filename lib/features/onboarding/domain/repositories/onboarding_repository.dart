import '../entities/onboarding_entity.dart';

abstract class OnboardingRepository {
  Future<void> saveOnboarding({
    required String email,
    required OnboardingEntity entity,
  });

  Future<bool> checkCompleted({
    required String email,
  });

  Future<OnboardingEntity?> getOnboarding({
    required String email,
  });

  Future<void> completeOnboarding({
    required String email,
  });
}

import '../../domain/entities/onboarding_entity.dart';

import '../../domain/repositories/onboarding_repository.dart';

import '../datasources/onboarding_local_datasource.dart';

import '../models/onboarding_model.dart';

class OnboardingRepositoryImpl implements OnboardingRepository {
  final OnboardingLocalDataSource localDataSource;

  const OnboardingRepositoryImpl({
    required this.localDataSource,
  });

  @override
  Future<void> saveOnboarding({
    required String email,
    required OnboardingEntity entity,
  }) async {
    final model = OnboardingModel(
      displayName: entity.displayName,
      occupation: entity.occupation,
      goals: entity.goals,
      currencyCode: entity.currencyCode,
      initialBalance: entity.initialBalance,
      onboardingCompleted: entity.onboardingCompleted,
    );

    await localDataSource.saveOnboarding(
      email: email,
      model: model,
    );
  }

  @override
  Future<bool> checkCompleted({
    required String email,
  }) async {
    return localDataSource.checkCompleted(
      email: email,
    );
  }

  @override
  Future<OnboardingEntity?> getOnboarding({
    required String email,
  }) async {
    final model = await localDataSource.getOnboarding(
      email: email,
    );

    if (model == null) {
      return null;
    }

    return OnboardingEntity(
      displayName: model.displayName,
      occupation: model.occupation,
      goals: model.goals,
      currencyCode: model.currencyCode,
      initialBalance: model.initialBalance,
      onboardingCompleted: model.onboardingCompleted,
    );
  }

  @override
  Future<void> completeOnboarding({
    required String email,
  }) async {
    final onboarding = await getOnboarding(
      email: email,
    );

    if (onboarding == null) {
      return;
    }

    final updatedEntity = OnboardingEntity(
      displayName: onboarding.displayName,
      occupation: onboarding.occupation,
      goals: onboarding.goals,
      currencyCode: onboarding.currencyCode,
      initialBalance: onboarding.initialBalance,
      onboardingCompleted: true,
    );

    await saveOnboarding(
      email: email,
      entity: updatedEntity,
    );
  }
}

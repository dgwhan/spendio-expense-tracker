import 'package:spend_io_app/features/auth/data/models/user_model.dart';
import 'package:spend_io_app/features/auth/domain/entities/user_entity.dart';

extension UserModelMapper on UserModel {
  UserEntity toAuthEntity() {
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

extension UserEntityMapper on UserEntity {
  UserModel toModel({String? displayName}) {
    return UserModel(
      id: id,
      email: email,
      password: password,
      displayName: displayName ?? displayNameField ?? email.split('@').first,
      occupation: occupation,
      financialGoal: financialGoal,
      preferredCurrencyCode: preferredCurrencyCode,
      onboardingCompleted: onboardingCompleted,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}

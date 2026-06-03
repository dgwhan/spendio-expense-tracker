import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/onboarding_entity.dart';
import '../../domain/repositories/onboarding_repository.dart';
import '../datasources/onboarding_local_datasource.dart';
import '../datasources/onboarding_remote_datasource.dart';
import '../models/onboarding_model.dart';

class OnboardingRepositoryImpl implements OnboardingRepository {
  final OnboardingLocalDataSource localDataSource;
  final OnboardingRemoteDataSource remoteDataSource;

  const OnboardingRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
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

    // Lưu cục bộ ở SQLite để offline
    await localDataSource.saveOnboarding(
      email: email,
      model: model,
    );

    // Đồng bộ hóa lên Cloud Firestore nếu người dùng đã đăng nhập Firebase
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      // Chạy bất đồng bộ ngầm để tránh làm nghẽn quá trình chuyển bước trên UI
      remoteDataSource.saveOnboarding(
        uid: uid,
        model: model,
      ).catchError((e) {
        // Bỏ qua lỗi đồng bộ khi offline hoặc lỗi Firestore
      });
    }
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
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid != null) {
      try {
        // Lấy dữ liệu mới nhất từ Firestore để cập nhật cache SQLite
        final remoteModel = await remoteDataSource.getOnboarding(uid: uid);
        if (remoteModel != null) {
          await localDataSource.saveOnboarding(email: email, model: remoteModel);
          return OnboardingEntity(
            displayName: remoteModel.displayName,
            occupation: remoteModel.occupation,
            goals: remoteModel.goals,
            currencyCode: remoteModel.currencyCode,
            initialBalance: remoteModel.initialBalance,
            onboardingCompleted: remoteModel.onboardingCompleted,
          );
        }
      } catch (_) {
        //bỏ qua lỗi khi kh có mạng
      }
    }

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

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:spend_io_app/core/database/app_database.dart';
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
    // 1. Kiểm tra dữ liệu cũ từ SQLite Local để lấy walletId hiện tại nhằm tái sử dụng
    final existingData = await localDataSource.getOnboarding(email: email);

    // Chiến thuật Re-use ID: Ưu tiên Local ID -> Ưu tiên Entity ID -> Khởi tạo mới theo timestamp
    final String walletId = existingData?.walletId ??
        (entity.walletId ?? 'acc_${DateTime.now().millisecondsSinceEpoch}');

    final model = OnboardingModel(
      displayName: entity.displayName,
      occupation: entity.occupation,
      goals: entity.goals,
      currencyCode: entity.currencyCode,
      initialBalance: entity.initialBalance,
      onboardingCompleted: entity.onboardingCompleted,
      walletId: walletId, // Kế thừa định danh ví duy nhất
    );

    // 2. Ghi dữ liệu xuống SQLite Local cache
    await localDataSource.saveOnboarding(
      email: email,
      model: model,
      walletId: walletId,
    );

    // 3. Đồng bộ dữ liệu lên Cloud Firestore nếu User đã được xác thực
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null && uid.trim().isNotEmpty) {
      try {
        final db = await AppDatabase.database;
        final userResult = await db.query(
          'users',
          columns: ['id'],
          where: 'email = ?',
          whereArgs: [email],
          limit: 1,
        );

        if (userResult.isNotEmpty) {
          final int localUserId = userResult.first['id'] as int;

          await remoteDataSource.saveOnboarding(
            uid: uid,
            model: model,
            walletId: walletId,
            localUserId: localUserId,
          );
          debugPrint('[Onboarding Repo]: Synced unified walletId: $walletId');
        }
      } catch (e) {
        debugPrint('[Onboarding Repo] Remote sync paused (Offline mode): $e');
      }
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
  Future<OnboardingEntity?> getOnboarding({required String email}) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid != null && uid.trim().isNotEmpty) {
      try {
        final remoteModel = await remoteDataSource.getOnboarding(uid: uid);
        if (remoteModel != null) {
          final existingLocalData =
              await localDataSource.getOnboarding(email: email);

          final String targetWalletId = remoteModel.walletId ??
              (existingLocalData?.walletId ??
                  'acc_${DateTime.now().millisecondsSinceEpoch}');

          return OnboardingEntity(
            displayName: remoteModel.displayName,
            occupation: remoteModel.occupation,
            goals: remoteModel.goals,
            currencyCode: remoteModel.currencyCode,
            initialBalance: remoteModel.initialBalance,
            onboardingCompleted: remoteModel.onboardingCompleted,
            walletId: targetWalletId,
          );
        }
      } catch (e) {
        debugPrint('[Onboarding Repo] Fetching remote onboarding failed: $e');
      }
    }

    // Fallback về local cache nếu thiết bị mất mạng
    final model = await localDataSource.getOnboarding(email: email);
    if (model == null) return null;

    return OnboardingEntity(
      displayName: model.displayName,
      occupation: model.occupation,
      goals: model.goals,
      currencyCode: model.currencyCode,
      initialBalance: model.initialBalance,
      onboardingCompleted: model.onboardingCompleted,
      walletId: model.walletId,
    );
  }

  @override
  Future<void> completeOnboarding({
    required String email,
    required OnboardingEntity
        entity, // 🟢 Đã sửa: Nhận trực tiếp entity từ ViewModel
  }) async {
    final updatedEntity = OnboardingEntity(
      displayName: entity.displayName,
      occupation: entity.occupation,
      goals: entity.goals,
      currencyCode: entity.currencyCode,
      initialBalance: entity.initialBalance,
      onboardingCompleted: true, // Khóa cứng trạng thái hoàn thành
      walletId: entity.walletId,
    );

    // Gọi hàm saveOnboarding để vừa cập nhật SQLite vừa đẩy trực tiếp data chuẩn lên Cloud
    await saveOnboarding(
      email: email,
      entity: updatedEntity,
    );
  }
}

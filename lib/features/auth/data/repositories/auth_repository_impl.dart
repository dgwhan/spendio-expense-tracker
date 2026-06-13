import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasource/auth_local_datasource.dart';
import '../datasource/auth_remote_datasource.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalDatasource localDatasource;
  final AuthRemoteDatasource remoteDatasource;

  AuthRepositoryImpl(this.localDatasource, this.remoteDatasource);

  @override
  Future<bool> register(UserEntity user) async {
    fb.User? firebaseUser;
    try {
      final displayName = user.email.split('@').first;

      // 1. Tạo tài khoản Firebase Auth & Firestore 
      final credential = await remoteDatasource.registerUser(
        email: user.email,
        password: user.password,
        displayName: displayName,
      ).timeout(const Duration(seconds: 5));
      firebaseUser = credential.user;

      // 2. Lưu vào SQLite cục bộ để chạy offline-first
      final model = UserModel(
        id: user.id,
        email: user.email,
        password: user.password,
        occupation: user.occupation,
        financialGoal: user.financialGoal,
        currency: user.currency,
        onboardingCompleted: user.onboardingCompleted,
        displayName: displayName,
        createdAt: DateTime.now(),
      );

      final localSuccess = await localDatasource.registerUser(model);
      if (!localSuccess) {
        throw Exception("Failed to save user in local SQLite database");
      }
      return true;
    } catch (e) {
      debugPrint("===> Lỗi đăng ký tại AuthRepositoryImpl: $e");
      // Rollback nếu có lỗi xảy ra sau khi Firebase đã tạo xong tài khoản
      if (firebaseUser != null) {
        await remoteDatasource.rollbackUser(user: firebaseUser);
      }
      return false;
    }
  }

  @override
  Future<UserEntity?> login(String email, String password) async {
    fb.UserCredential? credential;

    try {
      // 1. Đăng nhập qua Firebase Authentication (chờ tối đa 5s)
      credential = await remoteDatasource.loginUser(
        email: email,
        password: password,
      ).timeout(const Duration(seconds: 5));
    } catch (e) {
      // Offline fallback: Nếu đăng nhập Firebase Auth thất bại, thử đăng nhập bằng SQLite cục bộ
      final localResult = await localDatasource.loginUser(
        email: email,
        password: password,
      );

      if (localResult == null) return null;

      return UserEntity(
        id: localResult.id,
        email: localResult.email,
        password: localResult.password,
        occupation: localResult.occupation,
        financialGoal: localResult.financialGoal,
        currency: localResult.currency,
        onboardingCompleted: localResult.onboardingCompleted,
      );
    }

    final user = credential.user;
    if (user == null) return null;
    final uid = user.uid;
    Map<String, dynamic> userData = {};
    double? walletBalance;

    try {
      final profileSnap = await remoteDatasource
          .getUserProfile(uid: uid)
          .timeout(const Duration(seconds: 3));

      if (profileSnap.exists) {
        userData = profileSnap.data()!;
        walletBalance = await remoteDatasource
            .getWalletBalance(uid: uid)
            .timeout(const Duration(seconds: 2));
      }
    } catch (e) {
      // Bỏ qua lỗi Firestore nếu bị treo/mất kết nối để không chặn quá trình đăng nhập thành công
    }

    // 3. Đồng bộ hóa xuống SQLite local để offline-first
    final localModel = UserModel(
      email: email,
      password: password,
      displayName: userData['display_name'] ?? email.split('@').first,
      occupation: userData['occupation'] as String?,
      financialGoal: userData['financial_goal'] as String?,
      currency: userData['currency_code'] as String?,
      onboardingCompleted: userData['onboarding_completed'] == 1,
      createdAt: userData['created_at'] != null
          ? DateTime.parse(userData['created_at'] as String)
          : DateTime.now(),
    );

    await localDatasource.syncUserFromFirebase(localModel, walletBalance: walletBalance);

    // 4. Trả về thực thể UserEntity với id chính xác từ SQLite
    final dbUsers = await localDatasource.getAllUsers();
    final loggedInUser = dbUsers.firstWhere((u) => u.email == email);

    return UserEntity(
      id: loggedInUser.id,
      email: loggedInUser.email,
      password: loggedInUser.password,
      occupation: loggedInUser.occupation,
      financialGoal: loggedInUser.financialGoal,
      currency: loggedInUser.currency,
      onboardingCompleted: loggedInUser.onboardingCompleted,
    );
  }

  @override
  Future<bool> checkEmailExists(String email) async {
    // 1. Kiểm tra nhanh ở SQLite local
    final users = await localDatasource.getAllUsers();
    final existsLocal = users.any((e) => e.email == email);
    if (existsLocal) return true;

    // 2. Kiểm tra online trên Firestore thông qua remoteDatasource (chỉ đọc, tránh bị treo UI nhờ timeout 2 giây)
    try {
      return await remoteDatasource
          .checkEmailExists(email: email)
          .timeout(const Duration(seconds: 2));
    } catch (_) {
      // Fallback nếu không có mạng, bị chặn quyền truy cập hoặc timeout
      return false;
    }
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    final firebaseUser = fb.FirebaseAuth.instance.currentUser;
    if (firebaseUser == null) return null;

    final email = firebaseUser.email;
    if (email == null) return null;

    // Try finding the user in local SQLite DB first
    final dbUsers = await localDatasource.getAllUsers();
    UserModel? localUser;
    for (final u in dbUsers) {
      if (u.email == email) {
        localUser = u;
        break;
      }
    }

    // If not found locally, create a default local Model
    localUser ??= UserModel(
      id: null,
      email: email,
      password: '',
      displayName: firebaseUser.displayName ?? email.split('@').first,
      createdAt: DateTime.now(),
    );

    // Sync profile from Firestore if online
    Map<String, dynamic>? userData;
    double? walletBalance;
    try {
      final profileSnap = await remoteDatasource
          .getUserProfile(uid: firebaseUser.uid)
          .timeout(const Duration(seconds: 3));

      if (profileSnap.exists) {
        userData = profileSnap.data();
        walletBalance = await remoteDatasource
            .getWalletBalance(uid: firebaseUser.uid)
            .timeout(const Duration(seconds: 2));
      }
    } catch (e) {
      debugPrint("===> Error fetching remote profile in getCurrentUser: $e");
    }

    if (userData != null) {
      final syncedModel = UserModel(
        id: localUser.id,
        email: email,
        password: localUser.password.isNotEmpty ? localUser.password : '',
        displayName: userData['display_name'] ?? localUser.displayName ?? email.split('@').first,
        occupation: userData['occupation'] as String? ?? localUser.occupation,
        financialGoal: userData['financial_goal'] as String? ?? localUser.financialGoal,
        currency: userData['currency_code'] as String? ?? localUser.currency,
        onboardingCompleted: userData['onboarding_completed'] == 1,
        createdAt: userData['created_at'] != null
            ? DateTime.parse(userData['created_at'] as String)
            : localUser.createdAt,
      );

      await localDatasource.syncUserFromFirebase(syncedModel, walletBalance: walletBalance);
    }

    // Retrieve updated user to get accurate database ID and values
    final updatedDbUsers = await localDatasource.getAllUsers();
    final updatedLocalUser = updatedDbUsers.firstWhere(
      (u) => u.email == email,
      orElse: () => localUser!,
    );

    return UserEntity(
      id: updatedLocalUser.id,
      email: updatedLocalUser.email,
      password: updatedLocalUser.password,
      occupation: updatedLocalUser.occupation,
      financialGoal: updatedLocalUser.financialGoal,
      currency: updatedLocalUser.currency,
      onboardingCompleted: updatedLocalUser.onboardingCompleted,
    );
  }


  @override
  Future<void> logout() async {
    try {
      await remoteDatasource.logout();
    } finally {
      await localDatasource.logout();
    }
  }

  @override
  Future<void> updateOnboarding({required UserEntity user}) async {
    final model = UserModel(
      id: user.id,
      email: user.email,
      password: user.password,
      occupation: user.occupation,
      financialGoal: user.financialGoal,
      currency: user.currency,
      onboardingCompleted: user.onboardingCompleted,
      displayName: user.email.split('@').first,
      createdAt: DateTime.now(),
    );
    await localDatasource.updateOnboarding(model);
  }
}
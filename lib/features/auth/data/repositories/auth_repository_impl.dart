import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:cloud_firestore/cloud_firestore.dart';
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

      // 1. Ghi nhận thông tin vào SQLite Local TRƯỚC để làm điểm tựa dữ liệu offline
      final model = UserModel(
        id: user.id,
        email: user.email,
        password: user.password,
        occupation: user.occupation,
        financialGoal: user.financialGoal,
        preferredCurrencyCode: user.preferredCurrencyCode,
        onboardingCompleted: user.onboardingCompleted,
        displayName: displayName,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await localDatasource.registerUser(model);

      // 2. Kích hoạt đăng ký trên Firebase với thời gian chờ nới rộng lên 8 giây cho an toàn mạng
      final credential = await remoteDatasource
          .registerUser(
            email: user.email,
            password: user.password,
            displayName: displayName,
          )
          .timeout(const Duration(seconds: 8));

      firebaseUser = credential.user;
      return true;
    } on fb.FirebaseAuthException catch (firebaseError) {
      debugPrint(
          "===> [AuthRepositoryImpl] Firebase Specific Error: ${firebaseError.code}");

      if (firebaseError.code == 'email-already-in-use') {
        debugPrint(
            "[AuthRepositoryImpl] Email exists on Cloud. Retaining local storage row to heal sync split.");
        return true;
      }

      // Các lỗi cứng khác của Firebase thì tiến hành gỡ rác cục bộ
      if (firebaseUser != null) {
        await remoteDatasource.rollbackUser(user: firebaseUser);
      }
      await _cleanLocalTrash(user.email);
      return false;
    } catch (e) {
      debugPrint("===> [AuthRepositoryImpl] General / Timeout Error: $e");

      // Nếu dính TimeoutException, TUYỆT ĐỐI không xóa SQLite local, vì Firebase có thể sẽ tạo xong user sau vài giây ngầm
      if (e.toString().contains('TimeoutException')) {
        debugPrint(
            " [AuthRepositoryImpl] Timeout detected. Keeping local cache alive for potential ghost creation on Cloud.");
        return true;
      }

      await _cleanLocalTrash(user.email);
      return false;
    }
  }

  Future<void> _cleanLocalTrash(String email) async {
    try {
      await localDatasource.deleteUserByEmail(email);
    } catch (err) {
      debugPrint("[AuthRepositoryImpl] Failed to clean local warehouse: $err");
    }
  }

  @override
  Future<UserEntity?> login(String email, String password) async {
    fb.UserCredential? credential;

    try {
      credential = await remoteDatasource
          .loginUser(
            email: email,
            password: password,
          )
          .timeout(const Duration(seconds: 5));
    } catch (e) {
      // Offline fallback: Query local database directly if network invocation fails
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
        preferredCurrencyCode: localResult.preferredCurrencyCode,
        onboardingCompleted: localResult.onboardingCompleted,
      );
    }

    final user = credential.user;
    if (user == null) return null;
    final uid = user.uid;
    Map<String, dynamic> userData = {};
    double? walletBalance;
    String? firestoreWalletId;

    try {
      final profileSnap = await remoteDatasource
          .getUserProfile(uid: uid)
          .timeout(const Duration(seconds: 3));

      if (profileSnap.exists) {
        userData = profileSnap.data()!;

        final walletQuery = await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('wallets')
            .where('deleted_at', isNull: true)
            .limit(1)
            .get()
            .timeout(const Duration(seconds: 2));

        if (walletQuery.docs.isNotEmpty) {
          final walletDoc = walletQuery.docs.first;
          firestoreWalletId = walletDoc.id;
          walletBalance = (walletDoc.data()['balance'] as num?)?.toDouble();
        }
      }
    } catch (e) {
      debugPrint(
          "[AuthRepositoryImpl] Error downloading user profile snapshot from Firestore: $e");
    }

    final localModel = UserModel(
      email: email,
      password: password,
      displayName: userData['display_name'] ?? email.split('@').first,
      occupation: userData['occupation'] as String?,
      financialGoal: userData['financial_goal'] as String?,
      preferredCurrencyCode: userData['preferred_currency_code'] ?? userData['currency_code'] as String?,
      onboardingCompleted: userData['onboarding_completed'] == 1,
      createdAt: userData['created_at'] != null
          ? DateTime.parse(userData['created_at'] as String)
          : DateTime.now(),
      updatedAt: DateTime.now(),
    );

    // Secure database cache write: Prevents ghost rows from generating during login sync
    await localDatasource.syncUserFromFirebase(
      localModel,
      walletBalance: walletBalance,
      firestoreWalletId: firestoreWalletId,
    );

    final dbUsers = await localDatasource.getAllUsers();
    final loggedInUser = dbUsers.firstWhere((u) => u.email == email);

    return UserEntity(
      id: loggedInUser.id,
      email: loggedInUser.email,
      password: loggedInUser.password,
      occupation: loggedInUser.occupation,
      financialGoal: loggedInUser.financialGoal,
      preferredCurrencyCode: loggedInUser.preferredCurrencyCode,
      onboardingCompleted: loggedInUser.onboardingCompleted,
    );
  }

  @override
  Future<bool> checkEmailExists(String email) async {
    try {
      final firebaseResult = await remoteDatasource
          .checkEmailExists(email: email)
          .timeout(const Duration(seconds: 2));
      return firebaseResult;
    } catch (e) {
      debugPrint(
          "Firebase email check failed: $e, falling back to local storage query.");
      final users = await localDatasource.getAllUsers();
      return users.any((u) => u.email == email);
    }
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    final firebaseUser = remoteDatasource.currentUser;
    if (firebaseUser == null || firebaseUser.email == null) return null;

    final email = firebaseUser.email!;
    final users = await localDatasource.getAllUsers();
    final localUser = users.cast<UserModel?>().firstWhere(
          (u) => u?.email == email,
          orElse: () => null,
        );

    if (localUser != null) {
      return localUser.toEntity();
    }

    Map<String, dynamic> userData = {};
    double? walletBalance;
    String? firestoreWalletId;
    bool exists = false;

    try {
      final profileSnap = await remoteDatasource
          .getUserProfile(uid: firebaseUser.uid)
          .timeout(const Duration(seconds: 3));

      if (profileSnap.exists) {
        exists = true;
        userData = profileSnap.data()!;

        final walletQuery = await FirebaseFirestore.instance
            .collection('users')
            .doc(firebaseUser.uid)
            .collection('wallets')
            .where('deleted_at', isNull: true)
            .limit(1)
            .get()
            .timeout(const Duration(seconds: 2));

        if (walletQuery.docs.isNotEmpty) {
          final walletDoc = walletQuery.docs.first;
          firestoreWalletId = walletDoc.id;
          walletBalance = (walletDoc.data()['balance'] as num?)?.toDouble();
        }
      }
    } catch (e) {
      debugPrint(
          "[AuthRepositoryImpl] Failed to load user profile context in getCurrentUser: $e");
    }

    if (!exists) {
      return null;
    }

    final localModel = UserModel(
      email: email,
      password: '',
      displayName: userData['display_name'] ?? email.split('@').first,
      occupation: userData['occupation'] as String?,
      financialGoal: userData['financial_goal'] as String?,
      preferredCurrencyCode: userData['preferred_currency_code'] ?? userData['currency_code'] as String?,
      onboardingCompleted: userData['onboarding_completed'] == 1,
      createdAt: userData['created_at'] != null
          ? DateTime.parse(userData['created_at'] as String)
          : DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await localDatasource.syncUserFromFirebase(
      localModel,
      walletBalance: walletBalance,
      firestoreWalletId: firestoreWalletId,
    );

    final dbUsers = await localDatasource.getAllUsers();
    final syncedUser = dbUsers.cast<UserModel?>().firstWhere(
          (u) => u?.email == email,
          orElse: () => null,
        );

    return syncedUser?.toEntity();
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
      preferredCurrencyCode: user.preferredCurrencyCode,
      onboardingCompleted: user.onboardingCompleted,
      displayName: user.email.split('@').first,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await localDatasource.updateOnboarding(model);
  }

  @override
  Future<bool> checkWalletExists(String email) async {
    try {
      return await remoteDatasource
          .checkWalletExists(email: email)
          .timeout(const Duration(seconds: 3));
    } catch (e) {
      debugPrint(
          "[AuthRepositoryImpl] Error executing remote checkWalletExists check validation: $e");
      return false;
    }
  }
}

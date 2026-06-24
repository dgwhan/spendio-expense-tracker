import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import '../../../../core/database/app_database.dart';
import '../models/user_model.dart';

class AuthLocalDatasource {
  Future<bool> registerUser(UserModel user) async {
    final db = await AppDatabase.database;
    await db.insert(
      'users',
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return true;
  }

  Future<UserModel?> loginUser({
    required String email,
    required String password,
  }) async {
    final db = await AppDatabase.database;
    final result = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );
    if (result.isEmpty) return null;
    return UserModel.fromMap(result.first);
  }

  Future<List<UserModel>> getAllUsers() async {
    final db = await AppDatabase.database;
    final result = await db.query('users');
    return result.map((e) => UserModel.fromMap(e)).toList();
  }

  Future<UserModel?> getCurrentUser() async {
    return null;
  }

  Future<void> logout() async {
    // Không thực hiện xóa database cục bộ trên máy khi logout để giữ offline-first persistence
    debugPrint('[Auth Local]: Logged out successfully (kept local persistence intact).');
  }

  Future<void> updateOnboarding(UserModel user) async {
    final db = await AppDatabase.database;

    await db.update(
      'users',
      {
        'occupation': user.occupation,
        'financial_goal': user.financialGoal,
        'preferred_currency_code': user.preferredCurrencyCode,
        'onboarding_completed': user.onboardingCompleted ? 1 : 0,
      },
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  Future<void> syncUserFromFirebase(
    UserModel userModel, {
    double? walletBalance,
    String? firestoreWalletId,
  }) async {
    final db = await AppDatabase.database;

    final userResult = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [userModel.email],
      limit: 1,
    );

    int userId;
    if (userResult.isEmpty) {
      userId = await db.insert('users', userModel.toMap());
    } else {
      final localUserMap = userResult.first;
      userId = localUserMap['id'] as int;

      final String? finalCurrency =
          (userModel.preferredCurrencyCode != null && userModel.preferredCurrencyCode!.trim().isNotEmpty)
              ? userModel.preferredCurrencyCode
              : localUserMap['preferred_currency_code'] as String?;

      final int localStatusRaw =
          localUserMap['onboarding_completed'] as int? ?? 0;

      // Kiểm tra xem dữ liệu Firebase truyền xuống có chứa thông tin Onboarding hay chưa
      final bool hasOnboardingDataOnFirebase = (userModel.preferredCurrencyCode != null &&
              userModel.preferredCurrencyCode!.trim().isNotEmpty) ||
          (userModel.occupation != null &&
              userModel.occupation!.trim().isNotEmpty);

      // Nếu local đã là 1, hoặc Firebase báo true, hoặc Firebase chứa data tài chính -> Khóa cứng bằng 1
      final int finalOnboardingStatus = (localStatusRaw == 1 ||
              userModel.onboardingCompleted ||
              hasOnboardingDataOnFirebase)
          ? 1
          : 0;

      // In log bắt quả tang nếu có hiện tượng đè dữ liệu lỗi xảy ra:
      if (finalOnboardingStatus == 1 && localStatusRaw == 0) {
        debugPrint(
            '[Auth Local Safe Guard 🛡️]: Detected sync race condition! Forced onboarding_completed to 1 to protect local state.');
      }

      await db.update(
        'users',
        {
          'display_name': userModel.displayName,
          'occupation': userModel.occupation ?? localUserMap['occupation'],
          'financial_goal':
              userModel.financialGoal ?? localUserMap['financial_goal'],
          'preferred_currency_code': finalCurrency,
          'onboarding_completed':
              finalOnboardingStatus, // Luôn ghi số 1 vững chắc
          'updated_at': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [userId],
      );
    }

    if (walletBalance != null) {
      final walletResult = await db.query(
        'wallets',
        where: 'user_id = ?',
        whereArgs: [userId],
        limit: 1,
      );

      final nowStr = DateTime.now().toIso8601String();

      // Đọc lại trường bảo mật từ DB
      final userCheck = await db.query('users',
          columns: ['preferred_currency_code'], where: 'id = ?', whereArgs: [userId]);
      final String? verifiedCurrencyCode = userCheck.isNotEmpty
          ? userCheck.first['preferred_currency_code'] as String?
          : null;

      if (verifiedCurrencyCode == null || verifiedCurrencyCode.trim().isEmpty) {
        debugPrint(
            '[Auth Local Safe Guard]: Aborted default wallet initialization! Reason: Valid currency settings not found for User ID: $userId.');
        return;
      }

      // Khớp cấu trúc bảng wallets đại diện cho Account con của bạn
      if (walletResult.isEmpty) {
        final walletId =
            (firestoreWalletId != null && firestoreWalletId.trim().isNotEmpty)
                ? firestoreWalletId
                : 'acc_${DateTime.now().millisecondsSinceEpoch}';

        await db.insert('wallets', {
          'id': walletId,
          'user_id': userId,
          'wallet_name': 'Main Wallet',
          'wallet_type': 'cash',
          'balance': walletBalance,
          'currency_code': verifiedCurrencyCode,
          'icon_code_point': Icons.wallet.codePoint,
          'icon_font_family': 'MaterialIcons',
          'created_at': nowStr,
          'updated_at': nowStr,
          'deleted_at': null,
        });
        debugPrint(
            '[Auth Local]: Wallet synchronization completed successfully with currency code: $verifiedCurrencyCode');
      } else {
        await db.update(
          'wallets',
          {
            'balance': walletBalance,
            'currency_code': verifiedCurrencyCode,
            'updated_at': nowStr,
          },
          where: 'user_id = ?',
          whereArgs: [userId],
        );
      }
    }
  }

  Future<void> deleteUserByEmail(String email) async {
    final db = await AppDatabase.database;
    await db.delete(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
  }
}

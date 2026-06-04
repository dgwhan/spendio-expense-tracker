import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/onboarding_model.dart';

class OnboardingRemoteDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Đồng bộ hóa thông tin Onboarding và Ví của người dùng lên Cloud Firestore
  Future<void> saveOnboarding({
    required String uid,
    required OnboardingModel model,
  }) async {
    // 1. Cập nhật thông tin profile người dùng (dùng set và merge: true để tự tạo document nếu chưa tồn tại)
    await _firestore.collection('users').doc(uid).set({
      'display_name': model.displayName,
      'occupation': model.occupation,
      'financial_goal': model.goals.join(','),
      'currency_code': model.currencyCode,
      'onboarding_completed': model.onboardingCompleted ? 1 : 0,
      'updated_at': DateTime.now().toIso8601String(),
    }, SetOptions(merge: true));

    // 2. Đồng bộ hóa số dư Ví chính nếu có thiết lập
    if (model.initialBalance != null) {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('wallets')
          .doc('main')
          .set({
        'wallet_name': 'Main Wallet',
        'balance': model.initialBalance,
        'currency_code': model.currencyCode ?? 'VND',
        'created_at': DateTime.now().toIso8601String(),
      });
    }
  }

  /// Lấy thông tin Onboarding và số dư ví chính của người dùng từ Cloud Firestore
  Future<OnboardingModel?> getOnboarding({
    required String uid,
  }) async {
    final userSnap = await _firestore.collection('users').doc(uid).get();

    if (!userSnap.exists) {
      return null;
    }

    final userData = userSnap.data()!;

    // Lấy số dư ví chính từ Firestore subcollection
    final walletSnap = await _firestore
        .collection('users')
        .doc(uid)
        .collection('wallets')
        .doc('main')
        .get();

    double? initialBalance;
    if (walletSnap.exists) {
      initialBalance = (walletSnap.data()?['balance'] as num?)?.toDouble();
    }

    return OnboardingModel(
      displayName: userData['display_name'] as String?,
      occupation: userData['occupation'] as String?,
      goals: userData['financial_goal'] != null
          ? (userData['financial_goal'] as String)
              .split(',')
              .where((s) => s.isNotEmpty)
              .toList()
          : [],
      currencyCode: userData['currency_code'] as String?,
      initialBalance: initialBalance,
      onboardingCompleted: userData['onboarding_completed'] == 1,
    );
  }
}

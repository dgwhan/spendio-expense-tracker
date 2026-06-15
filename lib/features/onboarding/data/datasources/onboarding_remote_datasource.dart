import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/onboarding_model.dart';

class OnboardingRemoteDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveOnboarding({
    required String uid,
    required OnboardingModel model,
    required String walletId,
  }) async {
    await _firestore.collection('users').doc(uid).set({
      'display_name': model.displayName,
      'occupation': model.occupation,
      'financial_goal': model.goals.join(','),
      'currency_code': model.currencyCode,
      'onboarding_completed': model.onboardingCompleted ? 1 : 0,
      'updated_at': DateTime.now().toIso8601String(),
    }, SetOptions(merge: true));

    if (model.initialBalance != null) {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('wallets')
          .doc(walletId)
          .set({
        'wallet_name': 'Main Wallet',
        'wallet_type': 'cash',
        'balance': model.initialBalance,
        'currency_code': model.currencyCode ?? 'VND',
        'created_at': DateTime.now().toIso8601String(),
      });
    }
  }

  Future<OnboardingModel?> getOnboarding({
    required String uid,
  }) async {
    final userSnap = await _firestore.collection('users').doc(uid).get();

    if (!userSnap.exists) {
      return null;
    }

    final userData = userSnap.data()!;

    final walletSnap = await _firestore
        .collection('users')
        .doc(uid)
        .collection('wallets')
        .limit(1)
        .get();

    double? initialBalance;
    if (walletSnap.docs.isNotEmpty) {
      initialBalance =
          (walletSnap.docs.first.data()['balance'] as num?)?.toDouble();
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

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:spend_io_app/features/onboarding/data/models/onboarding_model.dart';

class OnboardingRemoteDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveOnboarding({
    required String uid,
    required OnboardingModel model,
    required String walletId,
    required int localUserId,
  }) async {
    if (uid.trim().isEmpty) return;

    final nowStr = DateTime.now().toIso8601String();

    final String? rawRemoteCurrency = model.currencyCode;
    if (rawRemoteCurrency == null || rawRemoteCurrency.trim().isEmpty) {
      debugPrint(
          '[Onboarding Remote Sync Paused]: Can not sync on Firestore because currencyCode empty.');
      return;
    }

    final String remoteCurrencyCode = rawRemoteCurrency;

    final Map<String, dynamic> userUpdateData = {
      'display_name': model.displayName,
      'occupation': model.occupation,
      'financial_goal': model.goals.join(','),
      'currency_code': remoteCurrencyCode,
      'onboarding_completed': 1,
      'updated_at': nowStr,
    };

    debugPrint('[FIREBASE TRACE] Preparing to update user document...');
    debugPrint('[FIREBASE TRACE] Target UID: $uid');
    debugPrint(
        '[FIREBASE TRACE] Payload sent to users collection: $userUpdateData');

    try {
      await _firestore.collection('users').doc(uid).update(userUpdateData);

      debugPrint(
          '[FIREBASE SUCCESS] Updated document users/$uid with onboarding_completed: 1');
    } catch (e) {
      debugPrint(
          '[FIREBASE ERROR] Failed to update user document, attempting fallback set-merge...');
      try {
        await _firestore
            .collection('users')
            .doc(uid)
            .set(userUpdateData, SetOptions(merge: true));
        debugPrint(
            '[FIREBASE SUCCESS] Executed fallback set-merge on users/$uid successfully.');
      } catch (innerError) {
        debugPrint(
            '[FIREBASE CRITICAL ERROR] Completely failed to write user data to Cloud: $innerError');
      }
    }

    await _firestore
        .collection('users')
        .doc(uid)
        .collection('wallets')
        .doc(walletId)
        .set({
      'id': walletId,
      'user_id': localUserId,
      'wallet_name': 'Main Wallet',
      'wallet_type': 'cash',
      'balance': model.initialBalance ?? 0.0,
      'currency_code': remoteCurrencyCode,
      'icon_code_point': 985044,
      'icon_font_family': 'MaterialIcons',
      'created_at': nowStr,
      'updated_at': nowStr,
      'deleted_at': null,
    }, SetOptions(merge: true));
  }

  Future<OnboardingModel?> getOnboarding({required String uid}) async {
    final userSnap = await _firestore.collection('users').doc(uid).get();

    if (!userSnap.exists) return null;

    final userData = userSnap.data()!;

    final walletSnap = await _firestore
        .collection('users')
        .doc(uid)
        .collection('wallets')
        .where('deleted_at', isNull: true)
        .limit(1)
        .get();

    double? initialBalance;
    String? currencyCode;
    String? walletId;

    if (walletSnap.docs.isNotEmpty) {
      final walletData = walletSnap.docs.first.data();
      initialBalance = (walletData['balance'] as num?)?.toDouble();
      currencyCode = walletData['currency_code'] as String?;
      walletId = walletData['id']?.toString();
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
      currencyCode: currencyCode ?? (userData['currency_code'] as String?),
      initialBalance: initialBalance,
      onboardingCompleted: userData['onboarding_completed'] == 1,
      walletId: walletId,
    );
  }
}

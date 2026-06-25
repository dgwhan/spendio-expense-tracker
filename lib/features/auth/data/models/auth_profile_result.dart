class AuthProfileResult {
  final Map<String, dynamic> userData;
  final double? walletBalance;
  final String? firestoreWalletId;

  const AuthProfileResult({
    required this.userData,
    this.walletBalance,
    this.firestoreWalletId,
  });
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;

class AuthRemoteDatasource {
  final fb.FirebaseAuth _auth = fb.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Đăng ký tài khoản Firebase và tạo profile Firestore
  Future<fb.UserCredential> registerUser({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final uid = userCredential.user!.uid;

    // Tạo document người dùng trên Firestore
    await _firestore.collection('users').doc(uid).set({
      'email': email,
      'display_name': displayName,
      'onboarding_completed': 0, 
      'created_at': DateTime.now().toIso8601String(),
    });

    return userCredential;
  }

  /// Đăng nhập Firebase  
  Future<fb.UserCredential> loginUser({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// Đăng xuất Firebase
  Future<void> logout() async {
    await _auth.signOut();
  }

  /// Lấy thông tin chi tiết của người dùng từ Firestore
  Future<DocumentSnapshot<Map<String, dynamic>>> getUserProfile({
    required String uid,
  }) async {
    return await _firestore.collection('users').doc(uid).get();
  }

  /// Kiểm tra email đã tồn tại trên Firestore chưa
  Future<bool> checkEmailExists({
    required String email,
  }) async {
    final query = await _firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    return query.docs.isNotEmpty;
  }

  /// Lấy số dư ví chính từ Firestore
  Future<double?> getWalletBalance({
    required String uid,
  }) async {
    final doc = await _firestore
        .collection('users')
        .doc(uid)
        .collection('wallets')
        .doc('main')
        .get();

    if (doc.exists) {
      return (doc.data()?['balance'] as num?)?.toDouble();
    }
    return null;
  }

  /// Rollback tài khoản Firebase Auth và document Firestore nếu đăng ký cục bộ thất bại
  Future<void> rollbackUser({
    required fb.User user,
  }) async {
    final uid = user.uid;
    try {
      await _firestore.collection('users').doc(uid).delete().timeout(const Duration(seconds: 2));
    } catch (_) {}
    try {
      await user.delete().timeout(const Duration(seconds: 2));
    } catch (_) {}
  }
}

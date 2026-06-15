import 'package:firebase_auth/firebase_auth.dart';

class ProfileRemoteDataSource {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> signOutFromCloud() async {
    await _auth.signOut();
  }
}

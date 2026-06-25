import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthDatasource {
  final fb.FirebaseAuth _auth;
  static const String _webClientId =
      '588910638568-k2gacrjbn5503emoopfpu6vg6pn8b9gh.apps.googleusercontent.com';

  bool _initialized = false;

  GoogleAuthDatasource({fb.FirebaseAuth? firebaseAuth})
      : _auth = firebaseAuth ?? fb.FirebaseAuth.instance;

  Future<void> _ensureInitialized() async {
    if (!_initialized) {
      await GoogleSignIn.instance.initialize(serverClientId: _webClientId);
      _initialized = true;
      debugPrint(
          '[GoogleAuthDatasource]: GoogleSignIn initialized successfully.');
    }
  }

  Future<fb.UserCredential?> signInWithGoogle() async {
    try {
      await _ensureInitialized();

      final googleSignIn = GoogleSignIn.instance;

      //authenticate() replaces the old signIn(); returns non-nullable account (throws on cancel)
      final GoogleSignInAccount googleUser = await googleSignIn.authenticate();

      //authentication is synchronous in this version of the plugin
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      // only idToken is available; accessToken was removed
      final fb.AuthCredential credential = fb.GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      final fb.UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      debugPrint(
        '[GoogleAuthDatasource]: Firebase sign-in successful — uid: ${userCredential.user?.uid}',
      );

      return userCredential;
    } on fb.FirebaseAuthException catch (e) {
      debugPrint(
        '[GoogleAuthDatasource]: FirebaseAuthException — code: ${e.code}, message: ${e.message}',
      );
      rethrow;
    } catch (e) {
      debugPrint('[GoogleAuthDatasource]: Unexpected error — $e');
      rethrow;
    }
  }

  ///Signs out from both Google and FirebaseAuth.
  Future<void> signOut() async {
    try {
      await Future.wait([
        GoogleSignIn.instance.signOut(),
        _auth.signOut(),
      ]);
      debugPrint('[GoogleAuthDatasource]: Signed out from Google + Firebase.');
    } catch (e) {
      debugPrint('[GoogleAuthDatasource]: Error during sign-out — $e');
    }
  }
}

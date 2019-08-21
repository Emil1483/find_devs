import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class User with ChangeNotifier {
  FirebaseUser _user;
  final GoogleSignIn _google = GoogleSignIn();
  FirebaseAuth _auth = FirebaseAuth.instance;

  FirebaseUser get user => _user;

  Future<bool> signUp({
    @required String email,
    @required String password,
  }) async {
    try {
      AuthResult result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      _user = result.user;
      print("Logged in as ${_user.displayName}");
      return true;
    } catch (e) {
      _user = null;
      print(e.message);
      return false;
    }
  }

  Future<bool> signInWithEmail({
    @required String email,
    @required String password,
  }) async {
    try {
      AuthResult result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _user = result.user;
      print("Logged in as ${_user.displayName}");
      return true;
    } catch (e) {
      _user = null;
      print(e.message);
      return false;
    }
  }

  Future<bool> googleSignIn() async {
    try {
      GoogleSignInAccount googleUser = await _google.signIn();
      GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      AuthResult result = await _auth.signInWithCredential(
        GoogleAuthProvider.getCredential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        ),
      );

      _user = result.user;
      print("Logged in as ${_user.displayName}");
      return true;
    } catch (e) {
      _user = null;
      print(e.message);
      return false;
    }
  }

  void logOut() {
    _auth.signOut();
    _user = null;
  }
}

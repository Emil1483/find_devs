import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class User with ChangeNotifier {
  FirebaseUser _user;
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

  void logOut() {
    _auth.signOut();
    _user = null;
  }
}

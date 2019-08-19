import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class User with ChangeNotifier {
  FirebaseUser _user;
  FirebaseAuth _auth = FirebaseAuth.instance;

  FirebaseUser get user => _user;

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
      print("Login succesfull");
      return true;
    } catch (e) {
      _user = null;
      print(e.message);
      return false;
    }
  }
}

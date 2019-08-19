import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class User with ChangeNotifier {
  FirebaseUser _user;
  FirebaseAuth _auth = FirebaseAuth.instance;

  FirebaseUser get user => _user;

  Future<void> signInWithEmail({
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
    } catch (e) {
      print(e.message);
      _user = null;
    }
  }
}

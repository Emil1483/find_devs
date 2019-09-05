import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum AuthError {
  UserNotFound,
  ExistingUser,
  PasswordNotValid,
  NetworkError,
  Unknown,
}

class UserData {
  bool lookForDevs;
  bool lookForWork;
  bool lookToCollab;
  bool hideFromMaps;
  String username;
  String about;
  String city;

  UserData({
    this.lookForDevs = false,
    this.lookForWork = false,
    this.lookToCollab = false,
    this.username,
    this.about,
    this.city,
    this.hideFromMaps = false,
  });

  factory UserData.fromMap(Map<String, dynamic> map) {
    return UserData(
      username: map["username"],
      about: map["about"],
      city: map["city"],
      hideFromMaps: map["hideFromMaps"],
      lookForDevs: map["lookForDevs"],
      lookForWork: map["lookForWork"],
      lookToCollab: map["lookToCollab"],
    );
  }
}

String getErrorMessage(AuthError error) {
  switch (error) {
    case AuthError.ExistingUser:
      return "That email is taken. Try another.";
    case AuthError.NetworkError:
      return "Check your internet.";
    case AuthError.PasswordNotValid:
      return "Wrong password.";
    case AuthError.UserNotFound:
      return "Could not find your account";
    case AuthError.Unknown:
      return "Please try again later.";
  }
  return "";
}

class User with ChangeNotifier {
  FirebaseUser _user;
  final GoogleSignIn _google = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Firestore _db = Firestore.instance;

  bool _waiting = true;

  FirebaseUser get user => _user;
  bool get waiting => _waiting;

  User() {
    autoLogin();
  }

  Future<void> autoLogin() async {
    FirebaseUser user = await _auth.currentUser();
    if (user != null) _user = user;
    _waiting = false;
    notifyListeners();
  }

  Future<AuthError> signUp({
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
      return null;
    } on PlatformException catch (e) {
      _user = null;
      return _getErrorType(e);
    }
  }

  Future<AuthError> signInWithEmail({
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
      return null;
    } on PlatformException catch (e) {
      _user = null;
      return _getErrorType(e);
    }
  }

  Future<AuthError> googleSignIn() async {
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
      return null;
    } on PlatformException catch (e) {
      _user = null;
      return _getErrorType(e);
    }
  }

  void logOut() {
    _auth.signOut();
    _user = null;
  }

  Future<bool> updateUserData(UserData data) async {
    try {
      DocumentReference ref = _db.collection("users").document(_user.uid);

      ref.setData({
        "uid": _user.uid,
        "email": _user.email,
        "lookForDevs": data.lookForDevs,
        "lookForWork": data.lookForWork,
        "lookToCollab": data.lookToCollab,
        "username": data.username,
        "about": data.about,
        "hideFromMaps": data.hideFromMaps,
        "city": data.city,
      });
      return true;
    } catch (e) {
      print("could not update user data: $e");
      return false;
    }
  }

  Future<UserData> getUserData() async {
    final result = await _db.collection("users").document(_user.uid).get();
    UserData userData = UserData.fromMap(result.data);
    if (userData.username == null && _user.displayName != null) {
      userData.username = _user.displayName;
      updateUserData(userData);
    }
    return userData;
  }

  AuthError _getErrorType(PlatformException e) {
    //TODO: Make sure this works for iOS!
    switch (e.code) {
      case "ERROR_USER_NOT_FOUND":
        return AuthError.UserNotFound;
      case "ERROR_WRONG_PASSWORD":
        return AuthError.PasswordNotValid;
      case "ERROR_NETWORK_REQUEST_FAILED":
        return AuthError.NetworkError;
      case "ERROR_EMAIL_ALREADY_IN_USE":
        return AuthError.ExistingUser;
      default:
        print("IMPLEMENT ERRORCODE ${e.code}");
        return AuthError.Unknown;
    }
  }
}

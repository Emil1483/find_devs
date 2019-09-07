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
  bool hideEmail;
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
    this.hideEmail = false,
  });

  factory UserData.fromMap(Map<String, dynamic> map) {
    return UserData(
      username: map["username"] ?? null,
      about: map["about"] ?? null,
      city: map["city"] ?? null,
      hideFromMaps: map["hideFromMaps"] ?? false,
      lookForDevs: map["lookForDevs"] ?? false,
      lookForWork: map["lookForWork"] ?? false,
      lookToCollab: map["lookToCollab"] ?? false,
      hideEmail: map["hideEmail"] ?? false,
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

  Future<bool> userDataExists() async {
    final result = await _db.collection("users").document(_user.uid).get();
    if (result.data == null) return false;
    return true;
  }

  Future<bool> updateUserData(UserData data) async {
    try {
      DocumentReference publicRef = _db
          .collection("users")
          .document(_user.uid)
          .collection("info")
          .document("public");

      DocumentReference privateRef = _db
          .collection("users")
          .document(_user.uid)
          .collection("info")
          .document("private");

      Map<String, dynamic> privateMap = {};
      Map<String, dynamic> publicMap = {
        "lookForDevs": data.lookForDevs,
        "lookForWork": data.lookForWork,
        "lookToCollab": data.lookToCollab,
        "username": data.username,
        "about": data.about,
        "hideFromMaps": data.hideFromMaps,
        "hideEmail": data.hideEmail,
      };

      void add(bool hide, String key, dynamic val) {
        hide ? privateMap[key] = val : publicMap[key] = val;
      }

      add(data.hideEmail, "email", _user.email);
      add(data.hideFromMaps, "city", data.city);

      publicRef.setData(publicMap);
      privateRef.setData(privateMap);
      return true;
    } catch (e) {
      print("could not update user data: $e");
      return false;
    }
  }

  bool _shouldUpdate(Map<String, dynamic> map) {
    if (map["username"] == null) return true;
    if (map["about"] == null) return true;
    if (map["city"] == null) return true;
    if (map["hideFromMaps"] == null) return true;
    if (map["lookForDevs"] == null) return true;
    if (map["lookForWork"] == null) return true;
    if (map["lookToCollab"] == null) return true;
    if (map["email"] == null) return true;
    if (map["uid"] == null) return true;
    if (map["hideEmail"]) return true;
    return false;
  }

  Map<String, dynamic> unpack(Map data) {
    Map<String, dynamic> map = {};
    for (var entrie in data.entries) {
      if (entrie.value is Map) {
        unpack(entrie.value).forEach((key, value) => map[key] = value);
        continue;
      } else {
        map[entrie.key] = entrie.value;
      }
    }
    return map;
  }

  Map<String, dynamic> combine(List<Map<String, dynamic>> data) {
    Map<String, dynamic> map = {};
    for (Map<String, dynamic> dataPoint in data) {
      unpack(dataPoint).forEach((key, value) => map[key] = value);
    }
    return map;
  }

  Future<UserData> getUserData() async {
    try {
      final public = await _db
          .collection("users")
          .document(_user.uid)
          .collection("info")
          .document("public")
          .get();
      final private = await _db
          .collection("users")
          .document(_user.uid)
          .collection("info")
          .document("private")
          .get();
      final Map<String, dynamic> data = combine([public.data, private.data]);

      UserData userData = UserData.fromMap(data);
      bool shouldUpdate = _shouldUpdate(data);

      if (userData.username == null || userData.username.isEmpty) {
        userData.username = _user.displayName;
        shouldUpdate = true;
      }
      if (shouldUpdate) updateUserData(userData);
      return userData;
    } catch (e) {
      print("could not get user data: $e");
      return UserData();
    }
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

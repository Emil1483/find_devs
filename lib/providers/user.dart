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
  String email;

  UserData({
    @required this.lookForDevs,
    @required this.lookForWork,
    @required this.lookToCollab,
    @required this.username,
    @required this.about,
    @required this.city,
    @required this.hideFromMaps,
    @required this.hideEmail,
    @required this.email,
  });

  factory UserData.fromMap(Map<String, dynamic> map,
      {String username, String email}) {
    return UserData(
      username: map["username"] ?? username,
      email: map["email"] ?? email,
      about: map["about"] ?? null,
      city: map["city"] ?? null,
      hideFromMaps: map["hideFromMaps"] ?? false,
      lookForDevs: map["lookForDevs"] ?? false,
      lookForWork: map["lookForWork"] ?? false,
      lookToCollab: map["lookToCollab"] ?? false,
      hideEmail: map["hideEmail"] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "username": username,
      "about": about,
      "city": city,
      "hideFromMaps": hideFromMaps,
      "lookForDevs": lookForDevs,
      "lookForWork": lookForWork,
      "lookToCollab": lookToCollab,
      "hideEmail": hideEmail,
      "email": email,
    };
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
      final CollectionReference ref =
          _db.collection("users").document(_user.uid).collection("info");

      final DocumentReference publicRef = ref.document("public");

      final DocumentReference privateRef = ref.document("private");

      Map<String, dynamic> privateMap = {};
      Map<String, dynamic> publicMap = data.toMap();

      void add(bool hide, String key, dynamic val) {
        if (!hide) return;
        privateMap[key] = val;
        publicMap.remove(key);
      }

      add(data.hideEmail, "email", _user.email);
      add(data.hideFromMaps, "city", data.city);

      await publicRef.setData(publicMap);
      await privateRef.setData(privateMap);
      return true;
    } catch (e) {
      print("could not update user data: $e");
      return false;
    }
  }

  bool _shouldUpdate(Map<String, dynamic> map) {
    for (String key in UserData.fromMap({}).toMap().keys) {
      if (map[key] == null) return true;
    }
    return false;
  }

  Map<String, dynamic> _unpack(Map data) {
    Map<String, dynamic> map = {};
    for (var entrie in data.entries) {
      if (entrie.value is Map) {
        _unpack(entrie.value).forEach((key, value) => map[key] = value);
        continue;
      } else {
        map[entrie.key] = entrie.value;
      }
    }
    return map;
  }

  Map<String, dynamic> _combine(List<Map<String, dynamic>> data) {
    Map<String, dynamic> map = {};
    for (Map<String, dynamic> dataPoint in data) {
      _unpack(dataPoint).forEach((key, value) => map[key] = value);
    }
    return map;
  }

  Future<UserData> getUserData() async {
    try {
      final CollectionReference ref =
          _db.collection("users").document(_user.uid).collection("info");
      final public = await ref.document("public").get();
      final private = await ref.document("private").get();

      final Map<String, dynamic> data = _combine([public.data, private.data]);

      UserData userData = UserData.fromMap(
        data,
        email: _user.email,
        username: _user.displayName,
      );

      if (_shouldUpdate(data)) updateUserData(userData);

      return userData;
    } catch (e) {
      print("could not get user data: $e");
      return UserData.fromMap({});
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

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';

import '../helpers/geohash_helper.dart';

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
  bool hideCity;
  bool hideEmail;
  String username;
  String about;
  String city;
  String email;
  String imageUrl;
  String geoHash;

  UserData({
    @required this.lookForDevs,
    @required this.lookForWork,
    @required this.lookToCollab,
    @required this.username,
    @required this.about,
    @required this.city,
    @required this.hideCity,
    @required this.hideEmail,
    @required this.email,
    @required this.imageUrl,
    @required this.geoHash,
  });

  @override
  String toString() => toMap().toString();

  factory UserData.fromMap(
    Map<String, dynamic> map, {
    String username,
    String email,
    String city,
    String imageUrl,
  }) {
    return UserData(
      username: map["username"] ?? username,
      email: map["email"] ?? email,
      city: map["city"] ?? city,
      about: map["about"] ?? null,
      hideCity: map["hideMaps"] ?? false,
      lookForDevs: map["lookForDevs"] ?? false,
      lookForWork: map["lookForWork"] ?? false,
      lookToCollab: map["lookToCollab"] ?? false,
      hideEmail: map["hideEmail"] ?? false,
      imageUrl: map["imageUrl"] ?? imageUrl,
      geoHash: map["geoHash"] ?? null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "username": username,
      "about": about,
      "city": city,
      "hideMaps": hideCity,
      "lookForDevs": lookForDevs,
      "lookForWork": lookForWork,
      "lookToCollab": lookToCollab,
      "hideEmail": hideEmail,
      "email": email,
      "imageUrl": imageUrl,
      "geoHash": geoHash,
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

  static const Duration timeoutDuration = Duration(seconds: 5);

  FirebaseUser get user => _user;
  bool get waiting => _waiting;

  User() {
    _autoLogin();
  }

  Future<void> _autoLogin() async {
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
    try {
      final CollectionReference ref =
          _db.collection("users").document(_user.uid).collection("info");

      final publicResult = await ref.document("public").get();
      if (publicResult.exists) return true;

      final privateResult = await ref.document("private").get();
      if (privateResult.exists) return true;

      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> _noInternet() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) return true;
    return false;
  }

  Future<bool> _removeFromPlaces(String prevHash) async {
    if (prevHash == null) return true;
    try {
      DocumentReference ref = _db.collection("places").document(prevHash);
      DocumentSnapshot snap = await ref.get();
      if (!snap.exists || snap.data[_user.uid] == null) return true;
      Map<String, dynamic> data = snap.data;
      data.remove(_user.uid);
      await ref.setData(data);
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> _addToPlaces(String geoHash, Map<String, dynamic> data) async {
    try {
      final ref = _db.collection("places").document(geoHash);
      await ref.setData({
        _user.uid: data,
      }, merge: true);
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<String> _getPrevGeoHash() async {
    try {
      DocumentReference ref = _db
          .collection("users")
          .document(_user.uid)
          .collection("info")
          .document("private");
      DocumentSnapshot snap = await ref.get();
      if (!snap.exists || snap.data["geoHash"] == null) return null;
      return snap.data["geoHash"];
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<bool> updateUserData(UserData data) async {
    if (await _noInternet()) return false;

    Map<String, dynamic> privateMap = {};
    Map<String, dynamic> publicMap = data.toMap();

    void add(bool hide, String key, dynamic val) {
      privateMap[key] = val;
      if (hide) publicMap.remove(key);
    }

    add(data.hideEmail, "email", _user.email);
    add(data.hideCity, "city", data.city);

    var addresses = await Geocoder.local.findAddressesFromQuery(data.city);
    Coordinates coordinates = addresses.first.coordinates;
    String geoHash = GeohashHelper.getHash(
      coordinates.latitude,
      coordinates.longitude,
    );

    add(true, "geoHash", geoHash);

    String prevHash = await _getPrevGeoHash();

    if (!await _removeFromPlaces(prevHash)) return false;
    if (!data.hideCity) if (!await _addToPlaces(geoHash, publicMap)) {
      return false;
    }

    try {
      final CollectionReference ref =
          _db.collection("users").document(_user.uid).collection("info");

      await ref.document("public").setData(publicMap);
      await ref.document("private").setData(privateMap);
      return true;
    } catch (e) {
      print("updateUserData: $e");
      return false;
    }
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

  Future<String> _getCityFromAddresses(List<Address> addresses) async {
    Address address = addresses.first;
    if (address.subAdminArea != null) return address.subAdminArea;
    return address.adminArea;
  }

  Future<String> _getCity() async {
    try {
      Position pos = await Geolocator().getCurrentPosition();
      final addresses = await Geocoder.local.findAddressesFromCoordinates(
        Coordinates(pos.latitude, pos.longitude),
      );
      return _getCityFromAddresses(addresses);
    } catch (e) {
      print("could not get city: $e");
      return null;
    }
  }

  Future<String> getCityFromQuery(String query) async {
    try {
      var addresses = await Geocoder.local.findAddressesFromQuery(query);
      return _getCityFromAddresses(addresses);
    } catch (e) {
      print("could not get city from query: $e");
      return null;
    }
  }

  Future<UserData> getUserData() async {
    if (await _noInternet()) return null;
    DocumentSnapshot public;
    DocumentSnapshot private;
    try {
      final CollectionReference ref =
          _db.collection("users").document(_user.uid).collection("info");

      public = await ref.document("public").get();
      private = await ref.document("private").get();
    } catch (e) {
      print("could not get user data: $e");
      return null;
    }

    final Map<String, dynamic> data = _combine([
      public.exists ? public.data : {},
      private.exists ? private.data : {},
    ]);

    String city = await _getCity();

    UserData userData = UserData.fromMap(
      data,
      email: _user.email,
      username: _user.displayName,
      city: city,
      imageUrl: _user.photoUrl,
    );

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

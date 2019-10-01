import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geocoder/geocoder.dart';

import '../helpers/geohash_helper.dart';
import './user.dart';

class Devs with ChangeNotifier {
  final Firestore _db = Firestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<UserData> _users = [];
  int _wantedLen = 0;
  bool _working = false;
  bool _loadedAllUsers = false;

  GeohashHelper _geohash;

  Devs() {
    _init();
  }

  bool get loadedAll => _loadedAllUsers;
  int get length => _users.length;
  UserData getUserByIndex(int index) => _users[index];

  void _init() async {
    FirebaseUser user = await _auth.currentUser();
    if (user == null) return;
    DocumentSnapshot snap = await _db
        .collection("users")
        .document(user.uid)
        .collection("info")
        .document("private")
        .get();
    if (!snap.exists || snap.data["city"] == null) return;

    var addresses =
        await Geocoder.local.findAddressesFromQuery(snap.data["city"]);
    Coordinates coordinates = addresses.first.coordinates;

    _geohash = GeohashHelper(coordinates.latitude, coordinates.longitude);
  }

  Future<UserData> getUser(int index) async {
    if (index < _users.length) return _users[index];
    _getMore(index + 1);
    while (index >= _users.length) {
      await Future.delayed(
        Duration(milliseconds: 200),
      );
    }
    return _users[index];
  }

  void _getMore(int newLen) async {
    if (newLen > _wantedLen) _wantedLen = newLen;
    if (_working) return;
    if (_loadedAllUsers) return;
    _working = true;
    while (_users.length < _wantedLen) {
      final List<UserData> moreUsers = await _moreUsers();
      if (moreUsers == null) {
        _loadedAllUsers = true;
        _working = false;
        await Future.delayed(Duration());
        notifyListeners();
        return;
      }
      _users.addAll(moreUsers);
      notifyListeners();
    }
    _working = false;
  }

  Future<List<UserData>> _moreUsers() async {
    while (_geohash == null) await Future.delayed(Duration(milliseconds: 500));
    try {
      final ref = _db.collection("places");
      DocumentSnapshot snap;
      String hash;
      while (snap == null || snap.data == null || snap.data.length == 0) {
        hash = _geohash.next();
        if (hash == null) return null;
        snap = await ref.document(hash).get();
      }
      List<UserData> result = [];
      FirebaseUser firebaseUser = await _auth.currentUser();
      String uid = firebaseUser.uid;
      snap.data.forEach((key, val) {
        if (uid != key) {
          Map<String, dynamic> data = Map<String, dynamic>.from(val);
          result.add(UserData.fromMap(data));
        }
      });

      return result;
    } catch (e) {
      print(e);
      return [];
    }
  }
}

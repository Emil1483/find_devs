import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geocoder/geocoder.dart';

import '../helpers/geohash_helper.dart';

class Devs with ChangeNotifier {
  final Firestore _db = Firestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Map<String, dynamic>> _users = [
    {"1": 1},
    {"1": 1},
    {"1": 1},
    {"1": 1},
    {"1": 1},
  ];
  int _wantedLen = 0;
  bool _working = false;
  bool _loadedAllUsers = false;

  GeohashHelper _geohash;

  Devs() {
    _init();
  }

  bool get loadedAll => _loadedAllUsers;
  int get length => _users.length;

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

  Future<Map<String, dynamic>> getUser(int index) async {
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
      final List<Map<String, dynamic>> moreUsers = await _moreUsers();
      if (moreUsers == null) {
        _loadedAllUsers = true;
        _working = false;
        await Future.delayed(Duration());
        notifyListeners();
        return;
      }
      _users.addAll(moreUsers);
    }
    _working = false;
  }

  Future<List<Map<String, dynamic>>> _moreUsers() async {
    while (_geohash == null) await Future.delayed(Duration(milliseconds: 500));

    final ref = _db.collection("places");
    DocumentSnapshot snap;
    String hash;
    while (snap == null || snap.data == null || snap.data.length == 0) {
      hash = _geohash.next();
      if (hash == null) return null;
      snap = await ref.document(hash).get();
    }
    print(snap.data);
    List<Map<String, dynamic>> result = [];
    snap.data.forEach(
      (key, val) => result.add(
        {key: val},
      ),
    );

    return result;
  }
}
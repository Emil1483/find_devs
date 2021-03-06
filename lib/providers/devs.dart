import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:rxdart/rxdart.dart';

import '../helpers/geohash_helper.dart';
import './user.dart';

class Devs with ChangeNotifier {
  final Firestore _db = Firestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<UserData> _users = [];
  int _wantedLen = 0;
  bool _error = false;
  bool _working = false;
  bool _loadedAllUsers = false;

  GeohashHelper _geohash;

  PublishSubject<String> _lastHash = PublishSubject();
  PublishSubject<String> _totalHashes = PublishSubject();

  HashSet<String> _animatedDevs = HashSet();

  Devs() {
    init();
  }

  bool get loadedAll => _loadedAllUsers;
  int get length => _users.length;

  Stream get lastHash => _lastHash.stream;
  Stream get totalHashes => _totalHashes.stream;
  int get maxHashes => GeohashHelper.totalCells;
  bool get error => _error;

  UserData getUserByIndex(int index) => _users[index];

  void init({Coordinates coordinates}) async {
    GeohashHelper geohashHelper = await _getGeohashHelper(coordinates);
    if (geohashHelper != null) _geohash = geohashHelper;

    _users.clear();
    _wantedLen = 0;
    _working = false;
    _loadedAllUsers = false;
    _error = false;
    _animatedDevs.clear();
    _totalHashes.add("0");
    notifyListeners();
  }

  Future<GeohashHelper> _getGeohashHelper(Coordinates coordinates) async {
    if (coordinates != null) {
      return GeohashHelper(coordinates.latitude, coordinates.longitude);
    }

    FirebaseUser user = await _auth.currentUser();
    if (user == null) return null;
    DocumentSnapshot snap = await _db
        .collection("users")
        .document(user.uid)
        .collection("info")
        .document("private")
        .get();

    var addresses = await _getAddresses(snap);
    if (addresses != null) {
      Coordinates coordinates = addresses.first.coordinates;
      return GeohashHelper(coordinates.latitude, coordinates.longitude);
    } else {
      Position pos = await Geolocator().getCurrentPosition();
      return GeohashHelper(pos.latitude, pos.longitude);
    }
  }

  void addToAnimated(String uid) {
    _animatedDevs.add(uid);
  }

  bool isAnimated(String uid) {
    return _animatedDevs.contains(uid);
  }

  Future<List<Address>> _getAddresses(DocumentSnapshot snap) async {
    if (!snap.exists || snap.data["city"] == null) return null;
    try {
      final addresses = await Geocoder.local.findAddressesFromQuery(
        snap.data["city"],
      );
      if (addresses.length == 0) return null;
      return addresses;
    } catch (e) {
      return null;
    }
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

    final ref = _db.collection("places");
    DocumentSnapshot snap;
    String hash;
    while (snap == null || snap.data == null || snap.data.length == 0) {
      hash = _geohash.next();
      _lastHash.add(hash);
      _totalHashes.add(_geohash.numHashes.toString());
      if (hash == null) return null;
      try {
        snap = await ref.document(hash).get();
      } on PlatformException catch (e) {
        print(e);
        _error = true;
        notifyListeners();
        return null;
      }
    }
    List<UserData> result = [];
    FirebaseUser firebaseUser;
    while (firebaseUser == null) {
      firebaseUser = await _auth.currentUser();
      if (firebaseUser == null)
        await Future.delayed(Duration(milliseconds: 500));
    }
    String uid = firebaseUser.uid;
    snap.data.forEach((key, val) {
      if (uid != key) {
        Map<String, dynamic> data = Map<String, dynamic>.from(val);
        result.add(UserData.fromMap(data, uid: key));
      }
    });

    return result;
  }
}

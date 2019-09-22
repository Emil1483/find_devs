import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Devs with ChangeNotifier {
  final Firestore _db = Firestore.instance;

  List<Map<String, dynamic>> _users = [];
  int _wantedLen = 0;
  bool _working = false;
  bool _loadedAllUsers = false;

  Future<Map<String, dynamic>> getUser(int index) async {
    if (index < _users.length) return _users[index];
    _getMore(index + 1);
    while (index >= _users.length) {
      await Future.delayed(
        Duration(milliseconds: 500),
      );
      if (_loadedAllUsers) return null;
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
        return;
      }
      _users.addAll(moreUsers);
    }
    _working = false;
  }

  Future<List<Map<String, dynamic>>> _moreUsers() async {
    final documentsData = await _db.collection("places").getDocuments();
    List<Map<String, dynamic>> result = [];
    documentsData.documents.forEach((DocumentSnapshot snap) {
      if (snap.data.length > 0) result.add(snap.data);
    });
    return result;
  }
}

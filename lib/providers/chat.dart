import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import './user.dart' show UserData;

class MessageData {
  final String from;
  final String timestamp;
  final String content;

  MessageData({
    @required this.from,
    @required this.timestamp,
    @required this.content,
  });

  factory MessageData.fromMap(Map<String, dynamic> map) {
    return MessageData(
      content: map["content"] ?? null,
      from: map["from"] ?? null,
      timestamp: map["timestamp"] ?? null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "from": from,
      "timestamp": timestamp,
      "content": content,
    };
  }
}

class Chat with ChangeNotifier {
  final UserData _userData;
  String _chatId;
  String _uid;

  final Firestore _db = Firestore.instance;

  Chat(this._userData, String uid) {
    _uid = uid;
    final String peerUid = _userData.uid;
    if (_uid.hashCode <= peerUid.hashCode) {
      _chatId = '$_uid-$peerUid';
    } else {
      _chatId = '$peerUid-$_uid';
    }
    _addToFriends();
  }

  UserData get userData => _userData.copy();
  String get uid => _uid;

  void _addToFriends() async {
    DocumentReference selfRef = _db
        .collection("users")
        .document(_uid)
        .collection("info")
        .document("friends");

    DocumentReference friendRef = _db
        .collection("users")
        .document(_userData.uid)
        .collection("info")
        .document("friends");

    await selfRef.setData({_userData.uid: _userData.toMap()}, merge: true); //TODO: Pass the frienddata extends userdata instead. Pass to friend as well.
    await friendRef.setData({_uid: false}, merge: true);
  }

  Stream<QuerySnapshot> get stream => Firestore.instance
      .collection("messages")
      .document(_chatId)
      .collection(_chatId)
      .orderBy("timestamp", descending: true)
      .limit(20)
      .snapshots();

  void sendMessage(String content) {
    DocumentReference ref = Firestore.instance
        .collection('messages')
        .document(_chatId)
        .collection(_chatId)
        .document(DateTime.now().millisecondsSinceEpoch.toString());
    Firestore.instance.runTransaction((Transaction transaction) async {
      await transaction.set(ref, {
        "from": _uid,
        "timestamp": DateTime.now().millisecondsSinceEpoch.toString(),
        "content": content,
      });
    });
  }
}

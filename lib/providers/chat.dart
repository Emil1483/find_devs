import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import './user.dart';

class MessageData {
  final String from;
  final String to;
  final String timestamp;
  final String content;

  MessageData({
    @required this.from,
    @required this.timestamp,
    @required this.content,
    @required this.to,
  });

  factory MessageData.fromMap(Map<String, dynamic> map) {
    return MessageData(
      content: map["content"] ?? null,
      from: map["from"] ?? null,
      timestamp: map["timestamp"] ?? null,
      to: map["to"] ?? null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "from": from,
      "timestamp": timestamp,
      "content": content,
      "to": to,
    };
  }
}

class Friend {
  final UserData userData;
  final bool seen;
  final MessageData latestMessage;

  Friend({
    @required this.userData,
    @required this.seen,
    @required this.latestMessage,
  });

  factory Friend.fromMap(Map<String, dynamic> map) {
    return Friend(
      userData: UserData.fromMap(
        Map<String, dynamic>.from(map["userData"]),
      ),
      seen: map["seen"],
      latestMessage: MessageData.fromMap(
        Map<String, dynamic>.from(map["latestMessage"]),
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "userData": userData.toMap(),
      "seen": seen,
      "latestMessage": latestMessage.toMap(),
    };
  }
}

class Chat with ChangeNotifier {
  UserData _userData;
  final User _user;
  String _chatId;
  String _uid;

  final Firestore _db = Firestore.instance;

  Chat(this._userData, this._user) {
    _uid = _user.user.uid;
    final String peerUid = _userData.uid;
    if (_uid.hashCode <= peerUid.hashCode) {
      _chatId = '$_uid-$peerUid';
    } else {
      _chatId = '$peerUid-$_uid';
    }
    _updateSeen();
  }

  UserData get userData => _userData.copy();
  String get uid => _uid;

  void updatePeerUserData(UserData userData) {
    _userData = userData;
    notifyListeners();
  }

  Future<MessageData> _getLatestMessage() async {
    try {
      QuerySnapshot snap = await Firestore.instance
          .collection("messages")
          .document(_chatId)
          .collection(_chatId)
          .orderBy("timestamp", descending: true)
          .limit(1)
          .getDocuments();

      if (snap.documents.length == 0) return null;

      return MessageData.fromMap(snap.documents.first.data);
    } catch (e) {
      print("could not fetch latest message: $e");
      return null;
    }
  }

  void _updateSeen() async {
    MessageData latestMessage = await _getLatestMessage();
    if (latestMessage == null) return;
    if (latestMessage.from == _uid) return;

    UserData myUserData = await _user.getPublicUserData();

    await _db
        .collection("users")
        .document(_uid)
        .collection("info")
        .document("friends")
        .updateData({
      _userData.uid: Friend(
        latestMessage: latestMessage,
        seen: true,
        userData: _userData,
      ).toMap(),
    });

    await _db
        .collection("users")
        .document(_userData.uid)
        .collection("info")
        .document("friends")
        .updateData({
      _uid: Friend(
        latestMessage: latestMessage,
        seen: true,
        userData: myUserData,
      ).toMap(),
    });
  }

  void _addToFriends(MessageData messageData) async {
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

    UserData myUserData = await _user.getPublicUserData();

    Friend me = Friend(
      latestMessage: messageData,
      seen: false,
      userData: myUserData,
    );

    Friend other = Friend(
      userData: _userData,
      latestMessage: messageData,
      seen: false,
    );

    await selfRef.setData({_userData.uid: other.toMap()}, merge: true);

    await friendRef.setData({_uid: me.toMap()}, merge: true);
  }

  Stream<QuerySnapshot> get stream => Firestore.instance
      .collection("messages")
      .document(_chatId)
      .collection(_chatId)
      .orderBy("timestamp", descending: true)
      .limit(100)
      .snapshots();

  void sendMessage(String content) {
    DocumentReference ref = Firestore.instance
        .collection('messages')
        .document(_chatId)
        .collection(_chatId)
        .document(DateTime.now().millisecondsSinceEpoch.toString());

    MessageData messageData = MessageData(
      from: _uid,
      to: _userData.uid,
      timestamp: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
    );
    _addToFriends(messageData);

    Firestore.instance.runTransaction((Transaction transaction) async {
      await transaction.set(
        ref,
        messageData.toMap(),
      );
    });
  }
}

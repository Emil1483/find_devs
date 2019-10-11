import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import './user.dart' show UserData;

class Chat with ChangeNotifier {
  final UserData _userData;
  String _chatId;
  String _uid;

  Chat(this._userData, String uid) {
    _uid = uid;
    final String peerUid = _userData.uid;
    if (_uid.hashCode <= peerUid.hashCode) {
      _chatId = '$_uid-$peerUid';
    } else {
      _chatId = '$peerUid-$_uid';
    }
    print(_chatId);
  }

  UserData get userData => _userData.copy();

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

  //TODO: Use https://medium.com/flutter-community/building-a-chat-app-with-flutter-and-firebase-from-scratch-9eaa7f41782e to complete the chat route
}

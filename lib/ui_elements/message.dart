import 'package:flutter/material.dart';

import '../providers/chat.dart' show MessageData;

class Message extends StatelessWidget {
  final MessageData messageData;
  final String uid;

  const Message(this.messageData, this.uid);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      margin: EdgeInsets.only(top: 16.0),
      color: messageData.from == uid
          ? Theme.of(context).accentColor
          : Theme.of(context).cardColor,
      child: Text(messageData.content),
    );
  }
}

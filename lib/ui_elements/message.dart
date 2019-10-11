import 'package:flutter/material.dart';

import '../providers/chat.dart' show MessageData;

class Message extends StatelessWidget {
  final MessageData messageData;

  const Message(this.messageData);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      margin: EdgeInsets.only(top: 16.0),
      color: Colors.orangeAccent,
    );
  }
}

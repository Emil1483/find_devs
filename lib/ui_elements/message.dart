import 'package:flutter/material.dart';

import '../providers/chat.dart' show MessageData;
import '../providers/user.dart' show UserData;

class Message extends StatelessWidget {
  final MessageData messageData;
  final String selfUid;
  final UserData otherUserData;

  const Message({
    @required this.messageData,
    @required this.selfUid,
    @required this.otherUserData,
  });

  Widget _buildIcon() {
    if (otherUserData.imageUrl == null || otherUserData.imageUrl.isEmpty) {
      return Padding(
        padding: EdgeInsets.only(right: 14.0),
        child: Icon(Icons.person),
      );
    } else {
      return Padding(
        padding: EdgeInsets.only(right: 14.0),
        child: CircleAvatar(
          backgroundImage: NetworkImage(
            otherUserData.imageUrl,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool sentBySelf = messageData.from == selfUid;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
      child: Row(
        mainAxisAlignment:
            sentBySelf ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: <Widget>[
          if (!sentBySelf) _buildIcon(),
          Container(
            constraints: BoxConstraints.loose(
              Size(
                MediaQuery.of(context).size.width * 0.7,
                double.infinity,
              ),
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18.0),
              color: sentBySelf
                  ? Theme.of(context).accentColor
                  : Theme.of(context).cardColor,
            ),
            padding: EdgeInsets.symmetric(horizontal: 13.0, vertical: 10.0),
            child: Text(
              messageData.content,
              style: TextStyle(
                color:
                    sentBySelf ? Theme.of(context).canvasColor : Colors.white,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

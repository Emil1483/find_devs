import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/user.dart';
import '../providers/chat.dart';
import '../ui_elements/friend_tile.dart';

class MessagesRoute extends StatelessWidget {
  static const String routeName = "/messages";

  Widget _buildList(BuildContext context) {
    if (MediaQuery.of(context).orientation == Orientation.portrait) {
      return Stack(
        children: <Widget>[
          Transform.scale(
            scale: 1.5,
            alignment: Alignment(0, -1.5),
            child: Image.asset(
              "assets/messages_vertical.png",
            ),
          ),
          Align(
            alignment: Alignment(0, 0.5),
            child: Text(
              "you have no messages yet",
              style: Theme.of(context).textTheme.title,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SizedBox(width: 52.0, height: 64.0),
          Expanded(
            flex: 3,
            child: Image.asset("assets/messages_icon.png"),
          ),
          Expanded(
            flex: 4,
            child: Center(
              child: Text(
                "you have no messages yet",
                style: Theme.of(context).textTheme.title,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    User user = Provider.of<User>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: Text("Messages"),
      ),
      body: StreamBuilder(
        stream: user.friendsStream,
        builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snap) {
          if (!snap.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          List<Friend> friends = user.friendList(snap.data);
          if (friends.length == 0) {
            return Center(
              child: _buildList(context),
            );
          }
          return ListView.builder(
            itemCount: friends.length,
            itemBuilder: (BuildContext context, int index) => FriendTile(
              friend: friends[index],
            ),
          );
        },
      ),
    );
  }
}

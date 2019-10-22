import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/user.dart';
import '../providers/chat.dart';
import '../ui_elements/friend_tile.dart';

class MessagesRoute extends StatelessWidget {
  static const String routeName = "/messages";

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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 64.0),
                    child: Image.asset("assets/missing_asset.png"),
                  ),
                  SizedBox(height: 32.0),
                  Text(
                    "you have no friends",
                    style: Theme.of(context).textTheme.title,
                  ),
                ],
              ),
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

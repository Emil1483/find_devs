import 'package:flutter/material.dart';

import '../providers/chat.dart' show Friend;

class FriendTile extends StatelessWidget {
  final Friend friend;

  FriendTile({@required this.friend});

  @override
  Widget build(BuildContext context) {
    //TODO: complete friend tile
    return Container(
      child: Text("friend: ${friend.userData.username}"),
    );
  }
}

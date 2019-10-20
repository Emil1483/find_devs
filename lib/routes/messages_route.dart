import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/user.dart';
import '../providers/chat.dart';
import '../ui_elements/friend_tile.dart';

class MessagesRoute extends StatefulWidget {
  static const String routeName = "/messages";

  @override
  _MessagesRouteState createState() => _MessagesRouteState();
}

class _MessagesRouteState extends State<MessagesRoute> {
  bool _loading = true;
  List<Friend> _friends;

  @override
  void initState() {
    _init();
    super.initState();
  }

  void _init() async {
    _friends = await Provider.of<User>(context, listen: false).getFriends();
    setState(() => _loading = false);
  }

  Widget _buildBody() {
    if (_loading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    } else if (_friends.length == 0) {
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
    } else {
      return ListView.builder(
        itemCount: _friends.length,
        itemBuilder: (BuildContext context, int index) => FriendTile(
          friend: _friends[index],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Messages"),
      ),
      body: _buildBody(),
    );
  }
}

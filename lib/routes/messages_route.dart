import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/user.dart';

class MessagesRoute extends StatefulWidget {
  static const String routeName = "/messages";

  @override
  _MessagesRouteState createState() => _MessagesRouteState();
}

class _MessagesRouteState extends State<MessagesRoute> {
  bool _loading = true;
  List<UserData> _friends;

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
    } else {
      return ListView.builder(
        itemCount: _friends.length,
        itemBuilder: (BuildContext context, int index) => Container(
          child: Text(_friends[index].username),
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

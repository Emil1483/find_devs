import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/chat.dart';

class ChatRoute extends StatefulWidget {
  static const String routeName = "/chat";

  @override
  _ChatRouteState createState() => _ChatRouteState();
}

class _ChatRouteState extends State<ChatRoute> {
  @override
  Widget build(BuildContext context) {
    Chat chat = Provider.of<Chat>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(chat.userData.username),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../providers/chat.dart';
import '../ui_elements/message.dart';

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
      body: StreamBuilder(
        stream: chat.stream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            final dokuments = snapshot.data.documents;
            return ListView.builder(
              itemCount: snapshot.data.documents.length,
              reverse: true,
              itemBuilder: (context, index) => Message(
                MessageData.fromMap(
                  dokuments[index].data,
                ),
                chat.uid,
              ),
            );
          }
        },
      ),
    );
  }
}

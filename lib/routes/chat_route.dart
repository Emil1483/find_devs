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
  TextEditingController _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Chat chat = Provider.of<Chat>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(chat.userData.username),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: StreamBuilder(
              stream: chat.stream,
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
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
                      messageData: MessageData.fromMap(
                        dokuments[index].data,
                      ),
                      selfUid: chat.uid,
                      otherUserData: chat.userData,
                    ),
                  );
                }
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(32.0),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    child: TextField(
                      controller: _textController,
                      keyboardType: TextInputType.multiline,
                      maxLines: 6,
                      minLines: 1,
                      decoration: InputDecoration(
                        hintText: "Type a message...",
                        contentPadding: EdgeInsets.zero,
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 4.0),
                IconButton(
                  color: Theme.of(context).accentColor,
                  icon: Icon(Icons.send),
                  onPressed: () {
                    if (_textController.text.isEmpty) return;
                    chat.sendMessage(_textController.text);
                    _textController.clear();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

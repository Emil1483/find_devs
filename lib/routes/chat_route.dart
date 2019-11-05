import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../providers/chat.dart';
import '../providers/user.dart';
import '../ui_elements/message.dart';
import '../ui_elements/alert_dialog.dart';

class ChatRoute extends StatefulWidget {
  static const String routeName = "/chat";

  @override
  _ChatRouteState createState() => _ChatRouteState();
}

class _ChatRouteState extends State<ChatRoute> {
  TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _init() async {
    Chat chat = Provider.of<Chat>(context, listen: false);
    User user = Provider.of<User>(context, listen: false);
    UserData newUserData = await user.updateFriend(
      chat.userData,
    );
    if (newUserData == null) return;
    chat.updatePeerUserData(newUserData);
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
                    itemCount: dokuments.length,
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
                  onPressed: () async {
                    if (_textController.text.isEmpty) return;
                    final connectivityResult =
                        await Connectivity().checkConnectivity();
                    if (connectivityResult == ConnectivityResult.none) {
                      showAlertDialog(
                        context,
                        title: "Error",
                        content: "Check your internet",
                      );
                      return;
                    }
                    try {
                      chat.sendMessage(_textController.text);
                    } catch (e) {
                      print(e);
                      return;
                    }
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

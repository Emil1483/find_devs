import 'package:flutter/material.dart';

import '../providers/chat.dart' show MessageData;
import '../providers/user.dart' show UserData;
import '../routes/dev_details_route.dart';

class Message extends StatelessWidget {
  final MessageData messageData;
  final String selfUid;
  final UserData otherUserData;

  const Message({
    @required this.messageData,
    @required this.selfUid,
    @required this.otherUserData,
  });

  void _showDialog(BuildContext context) {
    Navigator.push(
      context,
      HeroDialogRoute(
        builder: (BuildContext context) {
          return Center(
            child: Padding(
              padding: EdgeInsets.symmetric(
                vertical: 60,
                horizontal: 40,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: SingleChildScrollView(
                  child: Material(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.0,
                        vertical: 18.0,
                      ),
                      child: DevDetailsRoute.buildMain(
                        context: context,
                        userData: otherUserData,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildIcon() {
    if (otherUserData.imageUrl == null || otherUserData.imageUrl.isEmpty) {
      return Padding(
        padding: EdgeInsets.only(right: 14.0),
        child: Icon(Icons.person),
      );
    } else {
      return Padding(
        padding: EdgeInsets.only(right: 14.0),
        child: Hero(
          tag: otherUserData,
          child: CircleAvatar(
            backgroundImage: NetworkImage(
              otherUserData.imageUrl,
            ),
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
          if (!sentBySelf)
            GestureDetector(
              child: _buildIcon(),
              onTap: () => _showDialog(context),
            ),
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

class HeroDialogRoute<T> extends PageRoute<T> {
  HeroDialogRoute({this.builder}) : super();

  final WidgetBuilder builder;

  @override
  bool get opaque => false;

  @override
  bool get barrierDismissible => true;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 300);

  @override
  bool get maintainState => true;

  @override
  Color get barrierColor => Colors.black54;

  @override
  String get barrierLabel => null;

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    return new FadeTransition(
        opacity: new CurvedAnimation(parent: animation, curve: Curves.easeOut),
        child: child);
  }

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return builder(context);
  }
}

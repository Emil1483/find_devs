import 'package:flutter/material.dart';

import '../providers/chat.dart' show Friend;
import '../helpers/date_formatter.dart';
import '../routes/chat_route.dart';

class FriendTile extends StatelessWidget {
  final Friend friend;

  FriendTile({@required this.friend});

  Widget _buildIcon({double scale = 1.3}) {
    if (friend.userData.imageUrl == null || friend.userData.imageUrl.isEmpty) {
      return Center(child: Icon(Icons.person, size: 36.0 * scale));
    } else {
      return Center(
        child: CircleAvatar(
          backgroundImage: NetworkImage(friend.userData.imageUrl),
          radius: 22 * scale,
        ),
      );
    }
  }

  String _fromString() {
    if (friend.latestMessage.from == friend.userData.uid) {
      return friend.userData.username;
    } else {
      return "You";
    }
  }

  bool _shouldBeBold() {
    if (friend.seen) return false;
    return friend.latestMessage.from == friend.userData.uid;
  }

  Widget _buildCheck() {
    if (friend.latestMessage.from == friend.userData.uid) return Container();
    if (friend.seen) {
      return _buildIcon(scale: 0.5);
    } else {
      return Icon(
        Icons.check_circle,
        color: Colors.grey,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double iconWidth = 92;
    final double checkWidth = 64;
    final double dateWidth = 92;
    return Column(
      children: <Widget>[
        InkWell(
          onTap: () {
            Navigator.of(context).pushNamed(
              ChatRoute.routeName,
              arguments: friend.userData,
            );
          },
          child: Container(
            margin: EdgeInsets.symmetric(vertical: 6.0),
            height: 64,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  width: iconWidth,
                  child: _buildIcon(),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        friend.userData.username,
                        style: Theme.of(context).textTheme.body2,
                      ),
                      SizedBox(height: 5.0),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            constraints: BoxConstraints.loose(Size(
                              MediaQuery.of(context).size.width -
                                  iconWidth -
                                  checkWidth -
                                  dateWidth,
                              double.infinity,
                            )),
                            child: Text(
                              "${_fromString()}: ${friend.latestMessage.content}",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight:
                                    _shouldBeBold() ? FontWeight.bold : null,
                                color: _shouldBeBold()
                                    ? Colors.white
                                    : Colors.grey,
                              ),
                            ),
                          ),
                          Text(
                            " · ${formatFromString(friend.latestMessage.timestamp)}",
                            maxLines: 1,
                            style: TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: checkWidth,
                  child: _buildCheck(),
                ),
              ],
            ),
          ),
        ),
        Divider(
          height: 0,
        ),
      ],
    );
  }
}

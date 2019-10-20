import 'package:flutter/material.dart';

import '../providers/chat.dart' show Friend;
import '../helpers/date_formatter.dart';

class FriendTile extends StatelessWidget {
  final Friend friend;

  FriendTile({@required this.friend});

  Widget _buildIcon() {
    if (friend.userData.imageUrl == null || friend.userData.imageUrl.isEmpty) {
      return Center(child: Icon(Icons.person, size: 36.0));
    } else {
      return Center(
        child: Hero(
          tag: friend.userData,
          child: CircleAvatar(
            backgroundImage: NetworkImage(friend.userData.imageUrl),
            radius: 22,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double iconWidth = 82;
    final double checkWidth = 64;
    final double dateWidth = 92;
    return InkWell(
      onTap: () {},
      child: Container(
        padding: EdgeInsets.only(bottom: 4.0),
        height: 64,
        child: Row(
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
                          MediaQuery.of(context).size.width - iconWidth - checkWidth - dateWidth,
                          double.infinity,
                        )),
                        child: Text(
                          friend.latestMessage.content,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          softWrap: true,
                        ),
                      ),
                      Text(
                        " · ${formatFromString(friend.latestMessage.timestamp)}",
                        maxLines: 1,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(
              width: checkWidth,
              child: Icon(Icons.check_circle),
            ),
          ],
        ),
      ),
    );
  }
}

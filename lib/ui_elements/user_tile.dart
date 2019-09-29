import 'package:flutter/material.dart';

import '../providers/user.dart';

class UserTile extends StatelessWidget {
  final UserData userData;

  UserTile({@required this.userData});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8.0),
      child: Container(
        height: 182.0,
        color: Theme.of(context).cardColor,
        child: Column(
          children: <Widget>[
            Text(userData.username),
            Text(userData.about),
          ],
        ),
      ),
    );
  }
}

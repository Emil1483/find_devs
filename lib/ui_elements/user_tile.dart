import 'package:flutter/material.dart';

import '../providers/user.dart';

class UserTile extends StatelessWidget {
  final UserData userData;

  UserTile({@required this.userData});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: userData.imageUrl == null
          ? Icon(Icons.person)
          : CircleAvatar(
              backgroundImage: NetworkImage(
                userData.imageUrl,
              ),
            ),
      title: Text(userData.username),
      subtitle: Text(userData.about),
      onTap: () {},
    );
  }
}

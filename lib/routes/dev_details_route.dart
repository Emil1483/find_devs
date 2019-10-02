import 'package:flutter/material.dart';

import '../providers/user.dart';

class DevDetailsRoute extends StatelessWidget {
  final UserData userData;

  DevDetailsRoute({@required this.userData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(userData.username),
      ),
    );
  }
}

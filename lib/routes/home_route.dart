import 'package:flutter/material.dart';

import '../ui_elements/main_drawer.dart';

class HomeRoute extends StatelessWidget {
  static const String routeName = "/home";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Find Developers"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.chat),
            onPressed: () {},
          ),
        ],
      ),
      drawer: MainDrawer(),
    );
  }
}

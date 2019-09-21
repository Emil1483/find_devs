import 'package:flutter/material.dart';

import '../ui_elements/main_drawer.dart';

class ProjectsRoute extends StatelessWidget {
  static const String routeName = "/projects";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Find Projects"),
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

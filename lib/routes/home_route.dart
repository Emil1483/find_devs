import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../ui_elements/main_drawer.dart';
import '../ui_elements/user_tile.dart';
import '../providers/devs.dart';
import '../providers/user.dart';

class HomeRoute extends StatelessWidget {
  static const String routeName = "/home";

  Widget _buildBody(BuildContext context) {
    Devs devs = Provider.of<Devs>(context);
    return ListView.builder(
      itemCount: devs.loadedAll ? devs.length : devs.length + 1,
      padding: EdgeInsets.symmetric(horizontal: 8.0),
      itemBuilder: (BuildContext context, int index) {
        if (index <= devs.length - 1) {
          return UserTile(userData: devs.getUserByIndex(index));
        }
        return FutureBuilder(
          future: devs.getUser(index),
          builder: (BuildContext context, AsyncSnapshot<UserData> snapData) {
            return Container(
              height: 82.0,
              alignment: Alignment.center,
              child: CircularProgressIndicator(),
            );
          },
        );
      },
    );
  }

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
      body: _buildBody(context),
    );
  }
}

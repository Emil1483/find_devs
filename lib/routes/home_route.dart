import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../ui_elements/main_drawer.dart';
import '../providers/devs.dart';
import '../providers/user.dart';

class HomeRoute extends StatelessWidget {
  static const String routeName = "/home";

  @override
  Widget build(BuildContext context) {
    Devs devs = Provider.of<Devs>(context);
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
      body: ListView.builder(
        itemCount: devs.loadedAll ? devs.length : devs.length + 1,
        itemBuilder: (BuildContext context, int index) {
          return FutureBuilder(
            future: devs.getUser(index),
            builder: (BuildContext context,
                AsyncSnapshot<UserData> snapData) {
              if (snapData.connectionState != ConnectionState.done) {
                return Container(
                  height: 100,
                  alignment: Alignment.center,
                  child: CircularProgressIndicator(),
                );
              } else {
                return Container(
                  height: 100,
                  color: Color.lerp(Colors.orange, Colors.pink, index / 10),
                  child: Text("data: ${snapData.data.toString()}"),
                );
              }
            },
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../ui_elements/main_drawer.dart';
import '../ui_elements/user_tile.dart';
import '../providers/devs.dart';
import '../providers/user.dart';

class HomeRoute extends StatelessWidget {
  static const String routeName = "/home";

  StaggeredTile _staggeredTileBuilder(int index, BuildContext context) {
    if (MediaQuery.of(context).orientation == Orientation.portrait) {
      return StaggeredTile.fit(1);
    }
    Devs devs = Provider.of<Devs>(context, listen: false);
    if (index > devs.length - 1) return StaggeredTile.fit(2);
    return StaggeredTile.fit(1);
  }

  @override
  Widget build(BuildContext context) {
    Devs devs = Provider.of<Devs>(context);
    bool portrait = MediaQuery.of(context).orientation == Orientation.portrait;
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
      body: StaggeredGridView.countBuilder(
        padding: EdgeInsets.symmetric(horizontal: 8.0),
        itemCount: devs.loadedAll ? devs.length : devs.length + 1,
        crossAxisCount: portrait ? 1 : 2,
        staggeredTileBuilder: (int index) =>
            _staggeredTileBuilder(index, context),
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
      ),
    );
  }
}

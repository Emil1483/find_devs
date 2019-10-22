import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:badges/badges.dart';

import '../ui_elements/main_drawer.dart';
import '../ui_elements/user_tile.dart';
import '../providers/devs.dart';
import '../providers/user.dart';
import './messages_route.dart';

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
    User user = Provider.of<User>(context, listen: false);
    bool portrait = MediaQuery.of(context).orientation == Orientation.portrait;
    return Scaffold(
      appBar: AppBar(
        title: Text("Find Developers"),
        actions: <Widget>[
          IconButton(
            icon: StreamBuilder(
              stream: user.friendsStream,
              builder: (BuildContext context, AsyncSnapshot<dynamic> snap) {
                if (!snap.hasData) return Icon(Icons.chat);

                int notifications = user.notificationCount(
                  user.friendList(snap.data),
                );

                return Badge(
                  badgeContent: Text(
                    notifications.toString(),
                    style: TextStyle(
                      color: Theme.of(context).canvasColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  shape: BadgeShape.circle,
                  badgeColor: Theme.of(context).accentColor,
                  showBadge: notifications > 0,
                  child: Icon(Icons.chat),
                );
              },
            ),
            onPressed: () {
              Navigator.of(context).pushNamed(MessagesRoute.routeName);
            },
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

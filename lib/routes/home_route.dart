import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:badges/badges.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../ui_elements/main_drawer.dart';
import '../ui_elements/user_tile.dart';
import '../providers/devs.dart';
import '../providers/user.dart';
import './messages_route.dart';
import './error_route.dart';

class HomeRoute extends StatefulWidget {
  static const String routeName = "/home";

  @override
  _HomeRouteState createState() => _HomeRouteState();
}

class _HomeRouteState extends State<HomeRoute> {
  bool _navigated = false;

  StaggeredTile _staggeredTileBuilder(int index, BuildContext context) {
    if (MediaQuery.of(context).orientation == Orientation.portrait) {
      return StaggeredTile.fit(1);
    }
    Devs devs = Provider.of<Devs>(context, listen: false);
    if (index > devs.length - 1) return StaggeredTile.fit(2);
    return StaggeredTile.fit(1);
  }

  void _navigateToErrorRoute(BuildContext context) async {
    await Future.delayed(Duration());
    if (_navigated) return;
    _navigated = true;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => ErrorRoute(
          errorMessage: "Something went wrong",
          buttonChild: Text("Try Again"),
          buttonOnPressed: (BuildContext context) {
            Provider.of<Devs>(context).init();
            Navigator.of(context).pushReplacementNamed(HomeRoute.routeName);
          },
        ),
      ),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    User user = Provider.of<User>(context, listen: false);
    Devs devs = Provider.of<Devs>(context);
    bool portrait = MediaQuery.of(context).orientation == Orientation.portrait;

    if (devs.error && mounted) {
      _navigateToErrorRoute(context);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Find Developers"),
        actions: <Widget>[
          IconButton(
            icon: StreamBuilder(
              stream: user.friendsStream,
              builder: (
                BuildContext context,
                AsyncSnapshot<DocumentSnapshot> snap,
              ) {
                if (!snap.hasData || snap.data.data == null)
                  return Icon(Icons.chat);

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
              return Column(
                children: <Widget>[
                  Container(
                    height: 82.0,
                    alignment: Alignment.center,
                    child: CircularProgressIndicator(),
                  ),
                  StreamBuilder(
                    stream: devs.totalHashes,
                    builder: (_, AsyncSnapshot snap) {
                      ThemeData theme = Theme.of(context);
                      return Text(
                        "on geohash ${snap.data ?? 0} of ${devs.maxHashes}",
                        style: theme.textTheme.subhead.copyWith(
                          color: theme.disabledColor,
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 16.0),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

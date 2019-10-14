import 'package:flutter/material.dart';

import '../providers/user.dart';
import './chat_route.dart';

class DevDetailsRoute extends StatelessWidget {
  final UserData userData;

  DevDetailsRoute({@required this.userData});

  static Widget _buildImage(UserData userData) {
    return userData.imageUrl == null || userData.imageUrl.isEmpty
        ? Center(
            child: Container(
              width: 184.0,
              child: Image.asset("assets/account.png"),
            ),
          )
        : Center(
            child: Hero(
              tag: userData,
              child: CircleAvatar(
                radius: 92.0,
                backgroundImage: NetworkImage(
                  userData.imageUrl,
                ),
              ),
            ),
          );
  }

  static Widget _buildTop(BuildContext context, UserData userData) {
    bool portrait = MediaQuery.of(context).orientation == Orientation.portrait;
    if (portrait) {
      return Column(
        children: <Widget>[
          _buildImage(userData),
          SizedBox(height: 24.0),
          Text(userData.about, textAlign: TextAlign.center),
        ],
      );
    } else {
      return Row(
        children: <Widget>[
          Expanded(
            child: _buildImage(userData),
          ),
          Expanded(
            child: Text(userData.about),
          ),
        ],
      );
    }
  }

  static Widget _buildCheck(
    BuildContext context, {
    @required bool checked,
    @required IconData icon,
    @required String text,
  }) {
    TextTheme theme = Theme.of(context).textTheme;

    Widget buildIcon() {
      return Icon(
        icon,
        color: checked
            ? Theme.of(context).accentColor
            : Theme.of(context).disabledColor,
      );
    }

    Widget buildText() {
      return Text(
        text,
        textAlign: TextAlign.center,
        style: theme.subhead.copyWith(fontWeight: FontWeight.w300),
      );
    }

    if (MediaQuery.of(context).orientation == Orientation.portrait) {
      return Padding(
        padding: EdgeInsets.only(top: 16.0),
        child: Row(
          children: <Widget>[
            buildIcon(),
            SizedBox(width: 16.0),
            buildText(),
          ],
        ),
      );
    } else {
      return Column(
        children: <Widget>[
          buildIcon(),
          buildText(),
        ],
      );
    }
  }

  static Widget _buildChecks({
    @required BuildContext context,
    @required UserData userData,
  }) {
    List<Widget> children = [
      _buildCheck(
        context,
        checked: userData.lookToCollab,
        icon: Icons.code,
        text: "Looking to Collaborate",
      ),
      _buildCheck(
        context,
        checked: userData.lookForWork,
        icon: Icons.work,
        text: "Looking for Work",
      ),
      _buildCheck(
        context,
        checked: userData.lookForDevs,
        icon: Icons.person,
        text: "Looking for Developers",
      ),
    ];
    if (MediaQuery.of(context).orientation == Orientation.portrait) {
      return Column(
        children: children,
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: children,
      );
    }
  }

  static Widget buildMain({
    @required BuildContext context,
    @required UserData userData,
  }) {
    TextTheme theme = Theme.of(context).textTheme;
    return Column(
      children: <Widget>[
        _buildTop(context, userData),
        SizedBox(height: 24.0),
        Text(
          "City/state - ${userData.city}",
          textAlign: TextAlign.center,
          style: theme.subhead,
        ),
        SizedBox(height: 12.0),
        _buildChecks(
          context: context,
          userData: userData,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(userData.username),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.message),
        onPressed: () {
          Navigator.of(context).pushNamed(
            ChatRoute.routeName,
            arguments: userData,
          );
        },
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
        children: <Widget>[
          buildMain(
            context: context,
            userData: userData,
          ),
        ],
      ),
    );
  }
}

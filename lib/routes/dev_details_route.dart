import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../providers/user.dart';
import '../ui_elements/gradient button.dart';

class DevDetailsRoute extends StatelessWidget {
  final UserData userData;

  DevDetailsRoute({@required this.userData});

  Widget _buildImage() {
    return userData.imageUrl == null || userData.imageUrl.isEmpty
        ? Center(
            child: Container(
              width: 184.0,
              child: Image.asset("assets/account.png"),
            ),
          )
        : Center(
            child: CircleAvatar(
              radius: 92.0,
              backgroundImage: NetworkImage(
                userData.imageUrl,
              ),
            ),
          );
  }

  Widget _buildTop(BuildContext context) {
    bool portrait = MediaQuery.of(context).orientation == Orientation.portrait;
    if (portrait) {
      return Column(
        children: <Widget>[
          _buildImage(),
          SizedBox(height: 24.0),
          Text(userData.about, textAlign: TextAlign.center),
        ],
      );
    } else {
      return Row(
        children: <Widget>[
          Expanded(
            child: _buildImage(),
          ),
          Expanded(
            child: Text(userData.about),
          ),
        ],
      );
    }
  }

  Widget _buildCheck(BuildContext context,
      {bool checked, IconData icon, String text}) {
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

  Widget _buildButton(
    BuildContext context, {
    String text,
    IconData icon,
    Function onTap,
  }) {
    return GradientButton(
      onPressed: onTap,
      gradient: LinearGradient(
        colors: [
          Theme.of(context).accentColor,
          Theme.of(context).indicatorColor,
        ],
        begin: FractionalOffset.centerLeft,
        end: FractionalOffset.centerRight,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, color: Theme.of(context).canvasColor),
          SizedBox(width: 6.0),
          Text(
            text,
            style: TextStyle(
              color: Theme.of(context).canvasColor,
              fontWeight: FontWeight.w700,
              fontSize: 14.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChecks(BuildContext context) {
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

  @override
  Widget build(BuildContext context) {
    TextTheme theme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(userData.username),
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
        children: <Widget>[
          _buildTop(context),
          SizedBox(height: 24.0),
          Text(
            "City/state - ${userData.city}",
            textAlign: TextAlign.center,
            style: theme.subhead,
          ),
          SizedBox(height: 12.0),
          _buildChecks(context),
          SizedBox(height: 32.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              if (userData.email != null)
                _buildButton(
                  context,
                  icon: Icons.email,
                  text: "Send Email",
                  onTap: () async {
                    final url = "mailto:${userData.email}";
                    if (await canLaunch(url))
                      await launch(url);
                    else
                      throw "Could not launch $url";
                  },
                ),
              _buildButton(
                context,
                icon: Icons.message,
                text: "Send Message",
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}

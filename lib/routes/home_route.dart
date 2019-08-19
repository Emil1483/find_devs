import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/user.dart';

class HomeRoute extends StatelessWidget {
  static const String routeName = "/home";

  Widget _buildListTile({
    @required String text,
    @required Function onTap,
    Widget icon = const Icon(Icons.lock),
    String subtitle,
  }) {
    return ListTile(
      leading: icon,
      title: Text(text),
      onTap: onTap,
      subtitle: subtitle == null ? null : Text(subtitle),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: 28.0),
            child: Image(
              image: AssetImage("assets/missing_asset.png"),
              height: 144.0,
            ),
          ),
          _buildListTile(
            onTap: () {},
            text: "Find Devs",
            icon: Icon(Icons.account_circle),
          ),
          _buildListTile(
            onTap: () {},
            text: "Projects",
            subtitle: "Contract or collaboration",
            icon: Icon(Icons.code),
          ),
          _buildListTile(
            onTap: () {},
            text: "Privacy Policy",
          ),
          _buildListTile(
            text: "Logout",
            icon: Icon(Icons.exit_to_app),
            onTap: () {
              print("logout");
              Provider.of<User>(context, listen: false).logOut();
              Navigator.pushReplacementNamed(context, "/");
            },
          ),
        ],
      ),
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
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {},
          ),
        ],
      ),
      drawer: _buildDrawer(context),
    );
  }
}

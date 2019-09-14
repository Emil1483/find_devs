import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/user.dart';
import './auth_route.dart';
import './account_route.dart';

class HomeRoute extends StatelessWidget {
  static const String routeName = "/home";

  Widget _buildListTile(
    BuildContext context, {
    @required String text,
    @required Function onTap,
    Widget icon = const Icon(Icons.lock),
    String subtitle,
  }) {
    return ListTile(
      leading: icon,
      title: Text(text),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
      subtitle: subtitle == null ? null : Text(subtitle),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(
                top: 28.0,
                right: 64.0,
                left: 64.0,
              ),
              child: Image(
                image: AssetImage("assets/glasses.png"),
                height: 144.0,
              ),
            ),
            _buildListTile(
              context,
              onTap: () {},
              text: "Find Devs",
              icon: Icon(Icons.account_circle),
            ),
            _buildListTile(
              context,
              onTap: () {},
              text: "Projects",
              subtitle: "Contract or collaboration",
              icon: Icon(Icons.code),
            ),
            _buildListTile(
              context,
              onTap: () {
                Navigator.of(context).pushNamed(AccountRoute.routeName);
              },
              text: "Account Settings",
              icon: Icon(Icons.settings),
            ),
            _buildListTile(
              context,
              onTap: () {},
              text: "Privacy Policy",
            ),
            _buildListTile(
              context,
              text: "Logout",
              icon: Icon(Icons.exit_to_app),
              onTap: () {
                print("logout");
                Provider.of<User>(context, listen: false).logOut();
                Navigator.pushReplacementNamed(context, AuthRoute.routeName);
              },
            ),
          ],
        ),
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
        ],
      ),
      drawer: _buildDrawer(context),
      //TODO: Use this to add implement maps https://youtu.be/MYHVyl-juUk
    );
  }
}

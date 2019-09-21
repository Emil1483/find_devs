import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/user.dart';
import '../routes/account_route.dart';
import '../routes/auth_route.dart';
import '../routes/projects_route.dart';
import '../routes/home_route.dart';

class MainDrawer extends StatelessWidget {
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

  @override
  Widget build(BuildContext context) {
    ModalRoute modalRoute = ModalRoute.of(context);
    String currentRoute = modalRoute != null ? modalRoute.settings.name : null;
    bool home = currentRoute == HomeRoute.routeName;
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
              onTap: () {
                if (home) {
                  Navigator.of(context)
                      .pushReplacementNamed(ProjectsRoute.routeName);
                } else {
                  Navigator.of(context)
                      .pushReplacementNamed(HomeRoute.routeName);
                }
              },
              text: home ? "Find Projects" : "Find Developers",
              subtitle: home ?  "Contract or collaboration" : null,
              icon: home ?  Icon(Icons.code) : Icon(Icons.person),
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
                Provider.of<User>(context, listen: false).logOut();
                Navigator.pushReplacementNamed(context, AuthRoute.routeName);
              },
            ),
          ],
        ),
      ),
    );
  }
}

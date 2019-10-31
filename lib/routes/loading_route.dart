import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/user.dart';
import '../routes/home_route.dart';
import '../routes/auth_route.dart';
import '../routes/account_route.dart';

class LoadingRoute extends StatelessWidget {
  void _navigate(BuildContext context, String route) {
    Navigator.of(context).pushReplacementNamed(route);
  }

  void _autoAuth(BuildContext context, User user) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (user.waiting) return;
      if (user.user == null) {
        _navigate(context, AuthRoute.routeName);
        return;
      }
      if (await user.userDataExists()) {
        _navigate(context, HomeRoute.routeName);
        return;
      }
      _navigate(context, AccountRoute.routeName);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<User>(
      builder: (context, User user, Widget child) {
        _autoAuth(context, user);
        return child;
      },
      child: Scaffold(
        body: Container(
          alignment: Alignment.center,
          padding: EdgeInsets.all(64.0),
          child: Image.asset(
            "assets/glasses.png",
          ),
        ),
      ),
    );
  }
}

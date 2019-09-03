import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/user.dart';
import '../routes/home_route.dart';
import '../routes/auth_route.dart';

class LoadingRoute extends StatelessWidget {
  void autoAuth(BuildContext context, User user) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (user.waiting) return;
      if (user.user != null) {
        Navigator.of(context).pushReplacementNamed(HomeRoute.routeName);
      } else {
        Navigator.of(context).pushReplacementNamed(AuthRoute.routeName);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<User>(
      builder: (context, User user, Widget child) {
        autoAuth(context, user);
        return child;
      },
      child: Scaffold(
        appBar: AppBar(),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}

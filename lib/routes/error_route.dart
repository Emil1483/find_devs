import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../ui_elements/gradient button.dart';
import '../providers/devs.dart';
import './home_route.dart';

class ErrorRoute extends StatelessWidget {
  static const routeName = "/error";

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    bool portrait = MediaQuery.of(context).orientation == Orientation.portrait;

    List<Widget> children = <Widget>[
      Expanded(
        flex: portrait ? 3 : 1,
        child: Image.asset("assets/broken.png"),
      ),
      Expanded(
        child: Center(
          child: GradientButton(
            padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            onPressed: () {
              Provider.of<Devs>(context).init();
              Navigator.of(context).pushReplacementNamed(HomeRoute.routeName);
            },
            gradient: LinearGradient(
              colors: [
                theme.accentColor,
                theme.indicatorColor,
              ],
            ),
            child: Text(
              "Try again",
              style: theme.textTheme.button,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text("Error"),
      ),
      body: Center(
        child: portrait ? Column(children: children) : Row(children: children),
      ),
    );
  }
}
